-- Criação do Banco de Dados
CREATE DATABASE ECOSHARE;
USE ECOSHARE;

-- 1. Tabela de Tipos de Mensalidade
CREATE TABLE Mensalidade_tipo (
    id_mensalidade INT AUTO_INCREMENT,
    tipo_mensalidade VARCHAR(50) NOT NULL UNIQUE, -- Sem mensalidade, básica, plus

    PRIMARY KEY (id_mensalidade)
);

-- 2. Tabela de Usuários
CREATE TABLE Usuario (
    id_usuario INT AUTO_INCREMENT,
    mensalidade_id INT,
    nome_usuario VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    cpf CHAR(14) UNIQUE,
    cnpj CHAR(18) UNIQUE,
    hash_senha VARCHAR(255) NOT NULL,
    data_nascimento DATE NOT NULL,
    endereco VARCHAR(255),
    cep CHAR(9),

    PRIMARY KEY (id_usuario),

    FOREIGN KEY (mensalidade_id) REFERENCES Mensalidade_tipo(id_mensalidade)
        ON UPDATE CASCADE ON DELETE NO ACTION,

    CONSTRAINT usuario_com_cpf_e_cnpj CHECK (
    (cpf IS NOT NULL AND cnpj IS NULL) OR
    (cpf IS NULL AND cnpj IS NOT NULL))
);

-- 3. Tabela de Fotos de Perfil
CREATE TABLE Foto_perfil (
    id_foto_perfil INT AUTO_INCREMENT,
    usuario_id INT NOT NULL,
    endereco_cdn VARCHAR(255) NOT NULL,

    PRIMARY KEY (id_foto_perfil),

    FOREIGN KEY (usuario_id) REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 4. Tabela de Tipos de Permissão
CREATE TABLE Permissao (
    id_permissao INT AUTO_INCREMENT,
    tipo_permissao VARCHAR(31) NOT NULL UNIQUE, -- Administrador, Moderador, Usuário

    PRIMARY KEY (id_permissao)
);

-- 5. Tabela de concessões de permissão
CREATE TABLE Permissao_usuario (
    usuario_id INT,
    permissao_id INT,

    PRIMARY KEY (usuario_id, permissao_id),

    FOREIGN KEY (usuario_id) REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE,

    FOREIGN KEY (permissao_id) REFERENCES Permissao(id_permissao)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 6. Tabela de Categorias de Itens
CREATE TABLE Categoria_tipo (
    id_categoria INT AUTO_INCREMENT,
    tipo_categoria VARCHAR(50) NOT NULL UNIQUE, -- Ferramentas, eletrônicos, etc.

    PRIMARY KEY (id_categoria)
);

-- 7. Tabela de Estados de Conservação
CREATE TABLE Estado_tipo (
    id_estado INT AUTO_INCREMENT,
    tipo_estado VARCHAR(50) NOT NULL UNIQUE, -- Novo, usado, seminovo

    PRIMARY KEY (id_estado)
);

-- 8. Tabela de Disponibilidades de Itens
CREATE TABLE Disponibilidade_tipo (
    id_disponibilidade INT AUTO_INCREMENT,
    tipo_disponibilidade VARCHAR(50) NOT NULL UNIQUE, -- Disponível, Não disponível (doado), Em uso (emprestad/alugado), Em manutenção

    PRIMARY KEY (id_disponibilidade)
);

-- 9. Tabela de Itens
CREATE TABLE Item (
    id_item INT AUTO_INCREMENT,
    dono_id INT NOT NULL,
    nome_item VARCHAR(100) NOT NULL,
    categoria INT,
    disponibilidade INT, 
    descricao TEXT,
    estado_conservacao INT,

    PRIMARY KEY (id_item),

    FOREIGN KEY (categoria) REFERENCES Categoria_tipo(id_categoria)
        ON UPDATE CASCADE ON DELETE SET NULL,

    FOREIGN KEY (dono_id) REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE NO ACTION,

    FOREIGN KEY (disponibilidade) REFERENCES Disponibilidade_tipo(id_disponibilidade)
        ON UPDATE CASCADE ON DELETE NO ACTION,

    FOREIGN KEY (estado_conservacao) REFERENCES Estado_tipo(id_estado)
        ON UPDATE CASCADE ON DELETE NO ACTION
);

-- 10. Tabela de Fotos de Itens
CREATE TABLE Foto_item (
    id_foto_item INT AUTO_INCREMENT,
    item_id INT NOT NULL,
    endereco_cdn VARCHAR(255) NOT NULL,

    PRIMARY KEY (id_foto_item),

    FOREIGN KEY (item_id) REFERENCES Item(id_item)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 11. Tabela de Manutenção
CREATE TABLE Manutencao (
    id_manutencao INT AUTO_INCREMENT,
    item_id INT NOT NULL,
    data_inicio_manutencao DATE NOT NULL,
    data_fim_manutencao DATE,

    PRIMARY KEY (id_manutencao),

    FOREIGN KEY (item_id) REFERENCES Item(id_item)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 12. Tabela de Mensagens (Chat)
CREATE TABLE Mensagem (
    hash_mensagem CHAR(36), -- UUID
    item_id INT NOT NULL,
    remetente_id INT,
    destinatario_id INT,
    texto_mensagem TEXT NOT NULL,
    horario_mensagem TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (hash_mensagem),

    FOREIGN KEY (item_id) REFERENCES Item(id_item)
        ON UPDATE CASCADE ON DELETE CASCADE,

    FOREIGN KEY (remetente_id) REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE SET NULL,

    FOREIGN KEY (destinatario_id) REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE SET NULL
);

-- 13. Tabela de Pontos de Coleta
CREATE TABLE Ponto_coleta (
    id_coleta INT AUTO_INCREMENT,
    nome_coleta VARCHAR(100) NOT NULL UNIQUE,
    endereco_coleta VARCHAR(255),

    PRIMARY KEY (id_coleta)
);

-- 14. Tabela de Transações
CREATE TABLE Transacao (
    id_transacao INT AUTO_INCREMENT,
    item_id INT NOT NULL,
    vendedor_id INT NOT NULL,
    comprador_id INT,
    coleta_id INT,
    data_transacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_coleta TIMESTAMP,

    PRIMARY KEY (id_transacao),

    FOREIGN KEY (item_id) REFERENCES Item(id_item)
        ON UPDATE CASCADE ON DELETE NO ACTION,

    FOREIGN KEY (vendedor_id) REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE NO ACTION,

    FOREIGN KEY (comprador_id) REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE NO ACTION,

    FOREIGN KEY (coleta_id) REFERENCES Ponto_coleta(id_coleta)
        ON UPDATE CASCADE ON DELETE SET NULL
);

-- 15. Tabela de Transações de Aluguel
CREATE TABLE Aluguel (
    transacao_id INT,
    prev_devolucao DATE NOT NULL,
    data_devolucao DATE,
    preco DECIMAL(10, 2) NOT NULL,
    multa DECIMAL(10, 2), -- Gabriel: regra de negócio ctz

    PRIMARY KEY (transacao_id),

    FOREIGN KEY (transacao_id) REFERENCES Transacao(id_transacao)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 16. Tabela de Transações de Doação
CREATE TABLE Doacao (
    transacao_id INT,

    PRIMARY KEY (transacao_id),

    FOREIGN KEY (transacao_id) REFERENCES Transacao(id_transacao)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 17. Tabela de Transações de Empréstimo
CREATE TABLE Emprestimo (
    transacao_id INT,
    prev_devolucao DATE NOT NULL,
    data_devolucao DATE,
    update_date DATE, -- Gabriel: caso a previsão de devolução mude

    PRIMARY KEY (transacao_id),

    FOREIGN KEY (transacao_id) REFERENCES Transacao(id_transacao)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 18. Tabela de Avaliações
CREATE TABLE Avaliacao (
    transacao_id INT,
    avaliador_id INT,
    avaliado_id INT,
    nota INT CHECK (nota BETWEEN 0 AND 10),
    avaliacao TEXT, -- Gabriel: pode ser nula?

    PRIMARY KEY (transacao_id, avaliado_id),

    FOREIGN KEY (transacao_id) REFERENCES Transacao(id_transacao)
        ON UPDATE CASCADE ON DELETE CASCADE,

    FOREIGN KEY (avaliador_id) REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE SET NULL,

    FOREIGN KEY (avaliado_id) REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE
);