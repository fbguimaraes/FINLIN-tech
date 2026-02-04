from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPAuthorizationCredentials
from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from sqlalchemy.orm import Session
from decimal import Decimal
from datetime import date

# Importações locais
from auth import authenticate_user, validate_token, get_current_user_from_token
from repositories import (
    UsuarioRepository, ContaRepository, 
    CategoriaRepository, TransacaoRepository
)
from dependencies import (
    get_db_session, get_current_user_id,
    JSONResponse, security
)
from models import Usuario, Conta, Categoria, Transacao

print("=" * 70)
print("🚀 INICIALIZANDO API NA PORTA 8001")
print("=" * 70)

# ==================== SCHEMAS ====================

class LoginRequest(BaseModel):
    email: EmailStr
    password: str

class StdResponse(BaseModel):
    success: bool
    message: str
    data: Optional[dict] = None
    error: Optional[str] = None

class ContaCreate(BaseModel):
    nome: str = Field(..., min_length=1, max_length=255)
    saldo: Decimal = Field(default=Decimal("0.00"), ge=0)
    tipo: str = Field(..., min_length=1, max_length=50)

class CategoriaCreate(BaseModel):
    nome: str = Field(..., min_length=1, max_length=255)
    tipo: str = Field(..., pattern="^(receita|despesa)$")

class TransacaoCreate(BaseModel):
    valor: Decimal = Field(..., gt=0)
    data: date
    descricao: str = Field(..., min_length=1, max_length=500)
    tipo: str = Field(..., pattern="^(receita|despesa)$")
    id_conta: int = Field(..., gt=0)
    id_categoria: int = Field(..., gt=0)

class UsuarioCreate(BaseModel):
    nome: str = Field(..., min_length=1, max_length=255)
    email: EmailStr
    password: str = Field(..., min_length=6)


# ==================== INICIALIZAR APP ====================

app = FastAPI(
    title="Sistema Financeiro API",
    version="2.0.0",
    docs_url="/docs",
    description="API REST com autenticação JWT"
)

print("✓ FastAPI inicializado")

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

print("✓ CORS configurado")

# Repositórios
usuario_repo = UsuarioRepository()
conta_repo = ContaRepository()
categoria_repo = CategoriaRepository()
transacao_repo = TransacaoRepository()

print("✓ Repositórios carregados")


# ==================== ROTAS ====================

@app.get("/", tags=["Geral"])
async def root():
    """Rota raiz"""
    return {
        "success": True,
        "message": "API Online",
        "data": {
            "app": "Sistema Financeiro",
            "version": "2.0.0",
            "docs": "/docs",
            "port": 8001
        }
    }

@app.get("/api/health", tags=["Health"])
async def health():
    """Status da API"""
    return JSONResponse.success(data={"status": "healthy", "port": 8001})


# ==================== AUTH ====================

@app.post("/api/auth/login", response_model=StdResponse, tags=["Auth"])
async def login(credentials: LoginRequest):
    """
    Login - Retorna token JWT
    
    Credenciais de teste:
    - joao@email.com / senha123
    - maria@email.com / senha456
    """
    print(f"📧 Tentativa de login: {credentials.email}")
    result = authenticate_user(credentials.email, credentials.password)
    
    if not result["success"]:
        print(f"❌ Login falhou: {result.get('error')}")
        raise HTTPException(status_code=401, detail=result)
    
    print(f"✅ Login bem-sucedido: {credentials.email}")
    return result

@app.get("/api/auth/me", response_model=StdResponse, tags=["Auth"])
async def get_me(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """Dados do usuário autenticado"""
    token = credentials.credentials
    result = get_current_user_from_token(token)
    if not result["success"]:
        raise HTTPException(status_code=401, detail=result)
    return result

@app.post("/api/auth/validate", response_model=StdResponse, tags=["Auth"])
async def validate_user_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """Valida token JWT"""
    token = credentials.credentials
    result = validate_token(token)
    if not result["success"]:
        raise HTTPException(status_code=401, detail=result)
    return result


# ==================== USUÁRIOS ====================

@app.post("/api/usuarios", response_model=StdResponse, status_code=201, tags=["Usuários"])
async def criar_usuario(
    usuario_data: UsuarioCreate,
    db: Session = Depends(get_db_session)
):
    """Criar novo usuário (público)"""
    from auth import hash_password
    
    try:
        # Verificar email
        existing = usuario_repo.get_by_email(usuario_data.email, db=db)
        if existing["success"]:
            raise HTTPException(
                status_code=400,
                detail=JSONResponse.error("Email já cadastrado")
            )
        
        # Criar
        novo_usuario = Usuario(
            nome=usuario_data.nome,
            email=usuario_data.email,
            senha=hash_password(usuario_data.password)
        )
        
        db.add(novo_usuario)
        db.commit()
        db.refresh(novo_usuario)
        
        print(f"✅ Usuário criado: {novo_usuario.email}")
        
        return JSONResponse.success(
            data=novo_usuario.to_dict(),
            message="Usuário criado"
        )
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        print(f"❌ Erro ao criar usuário: {e}")
        raise HTTPException(status_code=500, detail=JSONResponse.error("Erro ao criar", str(e)))

@app.get("/api/usuarios", response_model=StdResponse, tags=["Usuários"])
async def listar_usuarios(
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db_session)
):
    """Listar usuários (requer auth)"""
    return usuario_repo.list_all(db=db)

@app.get("/api/usuarios/{id_usuario}", response_model=StdResponse, tags=["Usuários"])
async def obter_usuario(
    id_usuario: int,
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db_session)
):
    """Obter usuário (requer auth)"""
    result = usuario_repo.get_by_id(id_usuario, db=db)
    if not result["success"]:
        raise HTTPException(status_code=404, detail=result)
    return result


# ==================== CONTAS ====================

@app.get("/api/contas", response_model=StdResponse, tags=["Contas"])
async def listar_contas(
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db_session)
):
    """Listar contas do usuário"""
    return conta_repo.get_by_user(user_id, db=db)

@app.get("/api/contas/{conta_id}", response_model=StdResponse, tags=["Contas"])
async def obter_conta(
    conta_id: int,
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db_session)
):
    """Obter conta específica"""
    result = conta_repo.get_by_id(conta_id, db=db)
    if not result["success"]:
        raise HTTPException(status_code=404, detail=result)
    if result["data"]["id_usuario"] != user_id:
        JSONResponse.raise_forbidden()
    return result

@app.post("/api/contas", response_model=StdResponse, status_code=201, tags=["Contas"])
async def criar_conta(
    conta_data: ContaCreate,
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db_session)
):
    """Criar nova conta"""
    try:
        nova_conta = Conta(
            nome=conta_data.nome,
            saldo=conta_data.saldo,
            tipo=conta_data.tipo,
            id_usuario=user_id
        )
        
        db.add(nova_conta)
        db.commit()
        db.refresh(nova_conta)
        
        print(f"✅ Conta criada: {nova_conta.nome}")
        
        return JSONResponse.success(
            data=nova_conta.to_dict(),
            message="Conta criada"
        )
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=JSONResponse.error("Erro", str(e)))


# ==================== CATEGORIAS ====================

@app.get("/api/categorias", response_model=StdResponse, tags=["Categorias"])
async def listar_categorias(
    tipo: Optional[str] = None,
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db_session)
):
    """Listar categorias"""
    if tipo:
        return categoria_repo.get_by_tipo(user_id, tipo, db=db)
    return categoria_repo.get_by_user(user_id, db=db)

@app.post("/api/categorias", response_model=StdResponse, status_code=201, tags=["Categorias"])
async def criar_categoria(
    categoria_data: CategoriaCreate,
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db_session)
):
    """Criar categoria"""
    try:
        nova_categoria = Categoria(
            nome=categoria_data.nome,
            tipo=categoria_data.tipo,
            id_usuario=user_id
        )
        
        db.add(nova_categoria)
        db.commit()
        db.refresh(nova_categoria)
        
        return JSONResponse.success(
            data=nova_categoria.to_dict(),
            message="Categoria criada"
        )
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=JSONResponse.error("Erro", str(e)))


# ==================== TRANSAÇÕES ====================

@app.get("/api/transacoes", response_model=StdResponse, tags=["Transações"])
async def listar_transacoes(
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db_session)
):
    """Listar transações"""
    return transacao_repo.get_by_user(user_id, db=db)

@app.get("/api/transacoes/{transacao_id}", response_model=StdResponse, tags=["Transações"])
async def obter_transacao(
    transacao_id: int,
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db_session)
):
    """Obter transação"""
    result = transacao_repo.get_with_relationships(transacao_id, db=db)
    if not result["success"]:
        raise HTTPException(status_code=404, detail=result)
    if result["data"]["id_usuario"] != user_id:
        JSONResponse.raise_forbidden()
    return result

@app.post("/api/transacao", response_model=StdResponse, status_code=201, tags=["Transações"])
async def criar_transacao(
    transacao_data: TransacaoCreate,
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db_session)
):
    """Criar transação e atualizar saldo"""
    try:
        # Verificar conta
        conta_result = conta_repo.get_by_id(transacao_data.id_conta, db=db)
        if not conta_result["success"]:
            raise HTTPException(status_code=404, detail=JSONResponse.error("Conta não encontrada"))
        if conta_result["data"]["id_usuario"] != user_id:
            JSONResponse.raise_forbidden()
        
        # Verificar categoria
        categoria_result = categoria_repo.get_by_id(transacao_data.id_categoria, db=db)
        if not categoria_result["success"]:
            raise HTTPException(status_code=404, detail=JSONResponse.error("Categoria não encontrada"))
        if categoria_result["data"]["id_usuario"] != user_id:
            JSONResponse.raise_forbidden()
        
        # ✅ VALIDAR: Tipo da transação deve corresponder ao tipo da categoria
        tipo_categoria = categoria_result["data"]["tipo"].lower()
        tipo_transacao = transacao_data.tipo.lower()
        
        # Mapear: 'receita' da transação deve corresponder a categoria 'receita'
        # 'despesa' da transação deve corresponder a categoria 'despesa'
        if tipo_transacao != tipo_categoria:
            raise HTTPException(
                status_code=400, 
                detail=JSONResponse.error(
                    "Erro ao criar transação (400)",
                    f"Tipo da transacao ({tipo_transacao}) não corresponde ao tipo da categoria ({tipo_categoria})"
                )
            )
        
        # Criar transação
        nova_transacao = Transacao(
            valor=transacao_data.valor,
            data=transacao_data.data,
            descricao=transacao_data.descricao,
            tipo=transacao_data.tipo,
            id_usuario=user_id,
            id_conta=transacao_data.id_conta,
            id_categoria=transacao_data.id_categoria
        )
        
        # Atualizar saldo
        conta = db.query(Conta).filter(Conta.id_conta == transacao_data.id_conta).first()
        if transacao_data.tipo == "receita":
            conta.saldo += transacao_data.valor
        else:
            conta.saldo -= transacao_data.valor
        
        db.add(nova_transacao)
        db.commit()
        db.refresh(nova_transacao)
        
        print(f"✅ Transação criada: {nova_transacao.descricao}")
        
        return JSONResponse.success(
            data={
                **nova_transacao.to_dict(),
                "saldo_atualizado": float(conta.saldo)
            },
            message="Transação criada"
        )
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        print(f"❌ Erro: {e}")
        raise HTTPException(status_code=500, detail=JSONResponse.error("Erro", str(e)))


# ==================== DASHBOARD ====================

@app.get("/api/dashboard", response_model=StdResponse, tags=["Dashboard"])
async def dashboard(
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db_session)
):
    """Dashboard completo"""
    user_data = usuario_repo.get_by_id(user_id, db=db)
    contas_data = conta_repo.get_by_user(user_id, db=db)
    categorias_data = categoria_repo.get_by_user(user_id, db=db)
    transacoes_data = transacao_repo.get_by_user(user_id, db=db)

    return JSONResponse.success(data={
        "usuario": user_data.get("data"),
        "contas": contas_data.get("data", []),
        "categorias": categorias_data.get("data", []),
        "transacoes": transacoes_data.get("data", [])
    })


# ==================== STARTUP ====================

print("=" * 70)
print("✅ API PRONTA NA PORTA 8001")
print("📝 Docs: http://localhost:8001/docs")
print("🔐 Credenciais: joao@email.com / senha123")
print("=" * 70)


# ==================== EXECUTAR ====================

if __name__ == "__main__":
    import uvicorn
    print("\n🚀 Iniciando servidor na porta 8001...")
    uvicorn.run("main:app", host="0.0.0.0", port=8001, reload=True)
