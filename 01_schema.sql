-- Criação do Banco de Dados
CREATE DATABASE ECOSHARE;
USE ECOSHARE;

-- 1. Tabela de Tipos de Mensalidade
CREATE TABLE Mensalidade_tipo (
    id_mensalidade INT AUTO_INCREMENT,
    tipo_mensalidade VARCHAR(50) NOT NULL UNIQUE, -- Sem mensalidade, básica, plus

    PRIMARY KEY (id_mensalidade)
);

-- 2. Tabela de Permissões (RBAC)
CREATE TABLE Permissao (
    id_permissao INT,
    nome_permissao VARCHAR(40),

    PRIMARY KEY (id_permissao)
);

-- 3. Tabela de Fotos
CREATE TABLE Foto (
    id_foto INT AUTO_INCREMENT,
    endereco_cdn VARCHAR(255) NOT NULL,

    PRIMARY KEY (id_foto),
);

-- 4. Tabela de Endereços
CREATE TABLE Endereco (
    id_endereco INT AUTO_INCREMENT,
    cep CHAR(9),
    logradouro VARCHAR(255),
    numero VARCHAR(10),
    complemento VARCHAR(255),
    bairro VARCHAR(255),
    cidade VARCHAR(255),
    estado CHAR(2),

    PRIMARY KEY (id_endereco)
);

-- 5. Tabela de CPF e CNPJ
CREATE TABLE TipoPessoa (
    id_tipo_pessoa INT,
    tipo CHAR(2) NOT NULL UNIQUE, -- PF/PJ
    nome_tipo VARCHAR(50) NOT NULL UNIQUE,

    PRIMARY KEY (id_tipo_pessoa)
);

-- 6. Tabela de Usuários
CREATE TABLE Usuario (
    id_usuario INT AUTO_INCREMENT,
    mensalidade_id INT,
    nivel_permissao INT NOT NULL,
    foto_perfil_id INT,
    nome_usuario VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    tipo_pessoa INT,
    hash_senha VARCHAR(255) NOT NULL,
    data_nascimento DATE NOT NULL,
    saldo DECIMAL(10, 2) DEFAULT 0.00,
    endereco INT,
    cep CHAR(9),

    PRIMARY KEY (id_usuario),

    FOREIGN KEY (mensalidade_id) REFERENCES Mensalidade_tipo(id_mensalidade)
        ON UPDATE CASCADE ON DELETE NO ACTION,

    FOREIGN KEY (nivel_permissao) REFERENCES Permissao(id_permissao)
        ON UPDATE CASCADE ON DELETE NO ACTION,

    FOREIGN KEY (foto_perfil_id) REFERENCES Foto(id_foto)
        ON UPDATE CASCADE ON DELETE SET NULL,

    FOREIGN KEY (tipo_pessoa) REFERENCES TipoPessoa(id_tipo_pessoa)
        ON UPDATE CASCADE ON DELETE NO ACTION,

    FOREIGN KEY (endereco) REFERENCES Endereco(id_endereco)
        ON UPDATE CASCADE ON DELETE SET NULL
);

-- 7. Tabela de CPF 
CREATE TABLE Cpf (
    usuario_id INT,
    cpf CHAR(11) NOT NULL UNIQUE,

    PRIMARY KEY (usuario_id),

    FOREIGN KEY (usuario_id) REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 8. Tabela de CNPJ
CREATE TABLE Cnpj (
    usuario_id INT,
    cnpj CHAR(14) NOT NULL UNIQUE,

    PRIMARY KEY (usuario_id),

    FOREIGN KEY (usuario_id) REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 9. Tabela de Categorias de Itens
CREATE TABLE Categoria_tipo (
    id_categoria INT AUTO_INCREMENT,
    tipo_categoria VARCHAR(50) NOT NULL UNIQUE, -- Ferramentas, eletrônicos, etc.

    PRIMARY KEY (id_categoria)
);

-- 10. Tabela de Estados de Conservação
CREATE TABLE Estado_tipo (
    id_estado INT AUTO_INCREMENT,
    tipo_estado VARCHAR(50) NOT NULL UNIQUE, -- Novo, usado, seminovo

    PRIMARY KEY (id_estado)
);

-- 11. Tabela de Disponibilidades de Itens
CREATE TABLE Disponibilidade_tipo (
    id_disponibilidade INT AUTO_INCREMENT,
    tipo_disponibilidade VARCHAR(50) NOT NULL UNIQUE, -- Disponível, Não disponível (doado), Em uso (emprestad/alugado), Em manutenção

    PRIMARY KEY (id_disponibilidade)
);

-- 12. Tabela de Itens
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

-- 13. Tabela de Fotos de Itens
CREATE TABLE Foto_item (
    foto_id INT,
    item_id INT,

    PRIMARY KEY (foto_id, item_id),

    FOREIGN KEY (foto_id) REFERENCES Foto(id_foto)
        ON UPDATE CASCADE ON DELETE CASCADE,

    FOREIGN KEY (item_id) REFERENCES Item(id_item)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 14. Tabela de Manutenção
CREATE TABLE Manutencao (
    id_manutencao INT AUTO_INCREMENT,
    item_id INT NOT NULL,
    data_inicio_manutencao DATE NOT NULL,
    data_fim_manutencao DATE,

    PRIMARY KEY (id_manutencao),

    FOREIGN KEY (item_id) REFERENCES Item(id_item)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 15. Tabela de Mensagens (Chat)
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

-- 16. Tabela de Pontos de Coleta
CREATE TABLE Ponto_coleta (
    id_coleta INT AUTO_INCREMENT,
    nome_coleta VARCHAR(100) NOT NULL UNIQUE,
    endereco_coleta INT NOT NULL,

    PRIMARY KEY (id_coleta),

    FOREIGN KEY (endereco_coleta) REFERENCES Endereco(id_endereco)
        ON UPDATE CASCADE ON DELETE NO ACTION
);

CREATE TABLE Transacao_tipo (
    id_transacao_tipo INT,
    tipo_transacao VARCHAR(40) NOT NULL UNIQUE,

    PRIMARY KEY (id_transacao_tipo)
);

-- 17. Tabela de Transações
CREATE TABLE Transacao (
    id_transacao INT AUTO_INCREMENT,
    item_id INT NOT NULL,
    comprador_id INT,
    coleta_id INT,
    tipo_transacao INT NOT NULL,
    data_transacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_coleta TIMESTAMP,

    PRIMARY KEY (id_transacao),

    FOREIGN KEY (item_id) REFERENCES Item(id_item)
        ON UPDATE CASCADE ON DELETE NO ACTION,

    FOREIGN KEY (comprador_id) REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE NO ACTION,

    FOREIGN KEY (coleta_id) REFERENCES Ponto_coleta(id_coleta)
        ON UPDATE CASCADE ON DELETE SET NULL,

    FOREIGN KEY (tipo_transacao) REFERENCES Transacao_tipo(id_transacao_tipo)
        ON UPDATE CASCADE ON DELETE NO ACTION
);

-- 18. Tabela de Transações de Aluguel
CREATE TABLE Aluguel (
    transacao_id INT,
    prev_devolucao DATE NOT NULL,
    update_date DATE,
    data_devolucao DATE,
    preco DECIMAL(10, 2) NOT NULL,
    multa DECIMAL(10, 2), -- Gabriel: regra de negócio ctz

    PRIMARY KEY (transacao_id),

    FOREIGN KEY (transacao_id) REFERENCES Transacao(id_transacao)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 19. Tabela de Transações de Empréstimo
CREATE TABLE Emprestimo (
    transacao_id INT,
    prev_devolucao DATE NOT NULL,
    update_date DATE, -- Gabriel: caso a previsão de devolução mude
    data_devolucao DATE,

    PRIMARY KEY (transacao_id),

    FOREIGN KEY (transacao_id) REFERENCES Transacao(id_transacao)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 20. Tabela de Transações de Venda
CREATE TABLE Venda (
    transacao_id INT,
    preco DECIMAL(10, 2) NOT NULL,

    PRIMARY KEY (transacao_id),

    FOREIGN KEY (transacao_id) REFERENCES Transacao(id_transacao)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 21. Tabela de Avaliações
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

-- 22. Tabela de Métodos de Pagamento
CREATE TABLE Metodo_pagamento_tipo (
    id_metodo_pagamento INT,
    nome_metodo_pagamento VARCHAR(40) NOT NULL UNIQUE,

    PRIMARY KEY (id_metodo_pagamento)
);

-- 23. Tabela de Status de Pagamento
CREATE TABLE Status_pagamento_tipo (
    id_status_pagamento INT,
    nome_status_pagamento VARCHAR(40) NOT NULL UNIQUE,

    PRIMARY KEY (id_status_pagamento)
);

-- 24. Tabela de Pagamentos
CREATE TABLE Pagamento (
    id_pagamento INT,
    transacao_id INT NOT NULL,
    metodo_pagamento INT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    status_pagamento INT,
    data_pagamento TIMESTAMP,
    id_gateway_externo VARCHAR(100),

    PRIMARY KEY (id_pagamento),

    FOREIGN KEY (transacao_id) REFERENCES Transacao(id_transacao)
        ON UPDATE CASCADE ON DELETE NO ACTION,

    FOREIGN KEY (metodo_pagamento) REFERENCES Metodo_pagamento_tipo(id_metodo_pagamento)
        ON UPDATE CASCADE ON DELETE NO ACTION,

    FOREIGN KEY (status_pagamento) REFERENCES Status_pagamento_tipo(id_status_pagamento)
        ON UPDATE CASCADE ON DELETE NO ACTION
);

-- 25. Tabela de Estados de Denúncia
CREATE TABLE Denuncia_estado(
    id_denuncia_estado INT,
    denuncia_estado VARCHAR(40),

    PRIMARY KEY (id_denuncia_estado)
);

-- 26. Tabela de Tipos de Objeto
CREATE TABLE Objeto_tipo(
    id_objeto_tipo INT,
    objeto_tipo VARCHAR(40),

    PRIMARY KEY (id_objeto_tipo)
);

-- 27. Tabela de de Denúncias
CREATE TABLE Denuncia (
    id_denuncia INT AUTO_INCREMENT,
    denuncia_denunciador_id INT,
    denuncia_alvo_id INT,
    denuncia_alvo_tipo INT,
    denuncia_conteudo TINYTEXT,
    denuncia_data DATE,
    denuncia_estado INT,
    denuncia_responsavel INT,

    PRIMARY KEY (id_denuncia),

    FOREIGN KEY (denuncia_denunciador_id) REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE,

    FOREIGN KEY (denuncia_alvo_id) REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE NO ACTION,

    FOREIGN KEY (denuncia_alvo_tipo) REFERENCES Objeto_tipo(id_objeto_tipo)
        ON UPDATE CASCADE ON DELETE NO ACTION,
    
    FOREIGN KEY (denuncia_estado) REFERENCES Denuncia_estado(id_denuncia_estado)
        ON UPDATE CASCADE ON DELETE NO ACTION,

    FOREIGN KEY (denuncia_responsavel) REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE SET NULL
);