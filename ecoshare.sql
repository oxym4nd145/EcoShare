-- Criação do Banco de Dados
CREATE DATABASE ECOSHARE;
USE ECOSHARE;

-- 1. Tabela de Tipos de Permissão
CREATE TABLE Permissao_usuario (
    id_permissao INT,
    tipo_permissao VARCHAR(50) NOT NULL, -- Administrador, Moderador, Usuário
    PRIMARY KEY (id_permissao)
);

-- 2. Tabela de Tipos de Mensalidade
CREATE TABLE Mensalidade_tipo (
    id INT,
    tipo VARCHAR(50) NOT NULL, -- Sem mensalidade, básica, plus
    PRIMARY KEY (id)
);

-- 3. Tabela de Fotos de Perfil
CREATE TABLE Foto_perfil (
    id INT,
    endereco_CDN VARCHAR(255) NOT NULL,
    PRIMARY KEY (id)
);

-- 4. Tabela de Fotos de Itens
CREATE TABLE Foto_item (
    id INT,
    endereco_CDN VARCHAR(255) NOT NULL,
    PRIMARY KEY (id)
);

-- 5. Tabela de Categorias de Itens
CREATE TABLE Categoria_tipo (
    id INT,
    tipo VARCHAR(50) NOT NULL, -- Ferramentas, eletrônicos, etc.
    PRIMARY KEY (id)
);

-- 6. Tabela de Estados de Conservação
CREATE TABLE Estado_tipo (
    id INT,
    tipo VARCHAR(50) NOT NULL, -- Novo, usado, seminovo
    PRIMARY KEY (id)
);

-- 7. Tabela de Pontos de Coleta
CREATE TABLE Ponto_coleta (
    id_coleta INT,
    nome_coleta VARCHAR(100),
    endereco_coleta VARCHAR(255),
    PRIMARY KEY (id_coleta)
);

-- 8. Tabela de Tipos de Transação
CREATE TABLE Transacao_tipo (
    id INT,
    tipo VARCHAR(50) NOT NULL, -- Aluguel, empréstimo, doação
    PRIMARY KEY (id)
);

-- 9. Tabela de Usuários
CREATE TABLE Usuarios (
    id_usuario INT,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14),
    cnpj VARCHAR(18),
    permissao_usuario INT,
    tipo_mensalidade INT,
    id_foto INT,
    cep VARCHAR(9),
    endereco VARCHAR(255),
    PRIMARY KEY (id_usuario),
    FOREIGN KEY (permissao_usuario) REFERENCES Permissao_usuario(id_permissao),
    FOREIGN KEY (tipo_mensalidade) REFERENCES Mensalidade_tipo(id),
    FOREIGN KEY (id_foto) REFERENCES Foto_perfil(id)
);

-- 10. Tabela de Itens
CREATE TABLE Item (
    id INT,
    nome_item VARCHAR(100) NOT NULL,
    descricao TEXT,
    preco DECIMAL(10, 2),
    categoria INT,
    dono_id INT,
    estado_conservacao INT,
    id_fotos INT,
    PRIMARY KEY (id),
    FOREIGN KEY (categoria) REFERENCES Categoria_tipo(id),
    FOREIGN KEY (dono_id) REFERENCES Usuarios(id_usuario),
    FOREIGN KEY (estado_conservacao) REFERENCES Estado_tipo(id),
    FOREIGN KEY (id_fotos) REFERENCES Foto_item(id)
);

-- 11. Tabela de Manutenção
CREATE TABLE Manutencao (
    id_manutencao INT,
    id_item INT,
    data_inicio_manutencao DATE,
    data_final_manutencao DATE,
    PRIMARY KEY (id_manutencao),
    FOREIGN KEY (id_item) REFERENCES Item(id)
);

-- 12. Tabela de Transações
CREATE TABLE Transacao (
    id_transacao INT,
    id_item INT,
    id_comprador INT,
    id_vendedor INT,
    tipo INT,
    id_coleta INT,
    data_transacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_coleta TIMESTAMP,
    prev_devolucao DATE,
    PRIMARY KEY (id_transacao),
    FOREIGN KEY (id_item) REFERENCES Item(id),
    FOREIGN KEY (id_comprador) REFERENCES Usuarios(id_usuario),
    FOREIGN KEY (id_vendedor) REFERENCES Usuarios(id_usuario),
    FOREIGN KEY (tipo) REFERENCES Transacao_tipo(id),
    FOREIGN KEY (id_coleta) REFERENCES Ponto_coleta(id_coleta)
);

-- 13. Tabela de Avaliações
CREATE TABLE Avaliacao (
    id_transacao INT,
    id_item INT,
    avaliacao_comprador TEXT,
    avaliacao_vendedor TEXT,
    nota_comprador INT CHECK (nota_comprador BETWEEN 0 AND 10),
    nota_vendedor INT CHECK (nota_vendedor BETWEEN 0 AND 10),
    PRIMARY KEY (id_transacao),
    FOREIGN KEY (id_transacao) REFERENCES Transacao(id_transacao),
    FOREIGN KEY (id_item) REFERENCES Item(id)
);

-- 14. Tabela de Mensagens (Chat)
CREATE TABLE Mensagem (
    hash_mensagem CHAR(36), -- UUID
    id_item INT,
    id_comprador INT,
    texto_mensagem TEXT,
    direcao_de_envio VARCHAR(50), -- Quem mandou a mensagem
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (hash_mensagem),
    FOREIGN KEY (id_item) REFERENCES Item(id),
    FOREIGN KEY (id_comprador) REFERENCES Usuarios(id_usuario)
);