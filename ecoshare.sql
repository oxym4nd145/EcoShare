-- Criação do Banco de Dados
CREATE DATABASE ECOSHARE;
USE ECOSHARE;

-- 1. Tabela de Tipos de Permissão
CREATE TABLE Permissao_usuario (
    id_permissao INT PRIMARY KEY,
    tipo_permissao VARCHAR(50) NOT NULL -- Exemplos: Administrador, Moderador, Usuário
);

-- 2. Tabela de Tipos de Mensalidade
CREATE TABLE Mensalidade_tipo (
    id INT PRIMARY KEY,
    tipo VARCHAR(50) NOT NULL -- Exemplos: Sem mensalidade, básica, plus
);

-- 3. Tabela de Fotos (CDN)
CREATE TABLE Foto (
    id INT PRIMARY KEY,
    endereco_CDN VARCHAR(255) NOT NULL
);

-- 4. Tabela de Pontos de Coleta
CREATE TABLE Ponto_coleta (
    id_coleta INT PRIMARY KEY,
    nome_coleta VARCHAR(100),
    endereco_coleta VARCHAR(255)
);

-- 5. Tabela de Tipos de Transação
CREATE TABLE Transacao_tipo (
    id INT PRIMARY KEY,
    tipo VARCHAR(50) NOT NULL -- Exemplos: Aluguel, empréstimo, doação
);

-- 6. Tabela de Usuários
CREATE TABLE Usuarios (
    id_usuario INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14),
    cnpj VARCHAR(18),
    permissao_usuario INT,
    endereco VARCHAR(255),
    tipo_mensalidade INT,
    FOREIGN KEY (permissao_usuario) REFERENCES Permissao_usuario(id_permissao),
    FOREIGN KEY (tipo_mensalidade) REFERENCES Mensalidade_tipo(id)
);

-- 7. Tabela de Itens
CREATE TABLE Item (
    id INT PRIMARY KEY,
    nome_item VARCHAR(100) NOT NULL,
    descricao TEXT,
    preco DECIMAL(10, 2),
    categoria VARCHAR(50), -- Exemplos: ferramentas, eletrônicos, etc.
    dono_id INT,
    estado_conservacao VARCHAR(50),
    id_fotos INT,
    FOREIGN KEY (dono_id) REFERENCES Usuarios(id_usuario),
    FOREIGN KEY (id_fotos) REFERENCES Foto(id)
);

-- 8. Tabela de Manutenção
CREATE TABLE Manutencao (
    id_manutencao INT PRIMARY KEY,
    id_item INT,
    data_inicio_manutencao DATE,
    data_final_manutencao DATE,
    FOREIGN KEY (id_item) REFERENCES Item(id)
);

-- 9. Tabela de Transações
CREATE TABLE Transacao (
    id_transacao INT PRIMARY KEY,
    id_item INT,
    id_usuario1 INT, -- Comprador/Locatário
    id_usuario2 INT, -- Vendedor/Locador
    tipo INT,
    id_coleta INT,
    data_transacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_coleta TIMESTAMP,
    prev_devolucao DATE,
    FOREIGN KEY (id_item) REFERENCES Item(id),
    FOREIGN KEY (id_usuario1) REFERENCES Usuarios(id_usuario),
    FOREIGN KEY (id_usuario2) REFERENCES Usuarios(id_usuario),
    FOREIGN KEY (tipo) REFERENCES Transacao_tipo(id),
    FOREIGN KEY (id_coleta) REFERENCES Ponto_coleta(id_coleta)
);

-- 10. Tabela de Avaliações (Referente a uma transação concluída)
CREATE TABLE Avaliacao (
    id_transacao INT PRIMARY KEY,
    id_usuario1 INT,
    id_usuario2 INT,
    id_item INT,
    avaliacao1 TEXT, -- Comentário do usuário 1
    avaliacao2 TEXT, -- Comentário do usuário 2
    nota1 INT,       -- Nota dada pelo usuário 1
    nota2 INT,       -- Nota dada pelo usuário 2
    FOREIGN KEY (id_transacao) REFERENCES Transacao(id_transacao),
    FOREIGN KEY (id_usuario1) REFERENCES Usuarios(id_usuario),
    FOREIGN KEY (id_usuario2) REFERENCES Usuarios(id_usuario),
    FOREIGN KEY (id_item) REFERENCES Item(id)
);

-- 11. Tabela de Mensagens (Chat entre usuários sobre um item)
CREATE TABLE Mensagem (
    id_mensagem CHAR(36) PRIMARY KEY, -- UUID conforme indicado no diagrama
    id_item INT,
    id_usuario INT,   -- Remetente (quem mandou)
    id_usuario2 INT,  -- Destinatário
    mensagem TEXT,
    direcao VARCHAR(50), -- Descritivo de quem mandou
    data TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_item) REFERENCES Item(id),
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario),
    FOREIGN KEY (id_usuario2) REFERENCES Usuarios(id_usuario)
);