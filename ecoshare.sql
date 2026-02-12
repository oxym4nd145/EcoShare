-- 01_schema
-- Criação do Banco de Dados
CREATE DATABASE ECOSHARE;
USE ECOSHARE;

-- 1. Tabela de ID universal de objeto como alvo de denúncia
CREATE TABLE Alvo_ID (
    id_alvo INT AUTO_INCREMENT,
    tipo_objeto VARCHAR(40) NOT NULL,

    PRIMARY KEY (id_alvo)
);

-- 2. Tabela de Tipos de Mensalidade
CREATE TABLE Mensalidade_tipo (
    id_mensalidade INT AUTO_INCREMENT,
    tipo_mensalidade VARCHAR(50) NOT NULL UNIQUE, -- Sem mensalidade, básica, plus

    PRIMARY KEY (id_mensalidade)
);

-- 3. Tabela de Permissões (RBAC)
CREATE TABLE Permissao (
    id_permissao INT,
    nome_permissao VARCHAR(40),

    PRIMARY KEY (id_permissao)
);

-- 4. Tabela de Fotos
CREATE TABLE Foto (
    id_foto INT AUTO_INCREMENT,
    endereco_cdn VARCHAR(255) NOT NULL,

    PRIMARY KEY (id_foto)
);

-- 5. Tabela de Endereços
CREATE TABLE Endereco (
    id_endereco INT AUTO_INCREMENT,
    cep CHAR(9) NOT NULL,
    logradouro VARCHAR(255) NOT NULL,
    numero VARCHAR(10),
    complemento VARCHAR(255),
    bairro VARCHAR(255) NOT NULL,
    cidade VARCHAR(255) NOT NULL,
    estado CHAR(2) NOT NULL,

    PRIMARY KEY (id_endereco)
);

-- 6. Tabela de CPF e CNPJ
CREATE TABLE TipoPessoa (
    id_tipo_pessoa INT,
    tipo CHAR(2) NOT NULL UNIQUE, -- PF/PJ
    nome_tipo VARCHAR(50) NOT NULL UNIQUE,

    PRIMARY KEY (id_tipo_pessoa)
);

-- 7. Tabela de Usuários
CREATE TABLE Usuario (
    id_usuario INT AUTO_INCREMENT,
    mensalidade_id INT NOT NULL,
    nivel_permissao INT NOT NULL,
    foto_perfil_id INT,
    nome_usuario VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    tipo_pessoa INT NOT NULL,
    hash_senha VARCHAR(255) NOT NULL,
    data_nascimento DATE NOT NULL,
    saldo DECIMAL(10, 2) DEFAULT 0.00,
    endereco_id INT,

    alvo_id INT NOT NULL UNIQUE, -- Para denúncias

    PRIMARY KEY (id_usuario),

    FOREIGN KEY (mensalidade_id) REFERENCES Mensalidade_tipo(id_mensalidade)
        ON UPDATE CASCADE ON DELETE NO ACTION,

    FOREIGN KEY (nivel_permissao) REFERENCES Permissao(id_permissao)
        ON UPDATE CASCADE ON DELETE NO ACTION,

    FOREIGN KEY (foto_perfil_id) REFERENCES Foto(id_foto)
        ON UPDATE CASCADE ON DELETE SET NULL,

    FOREIGN KEY (tipo_pessoa) REFERENCES TipoPessoa(id_tipo_pessoa)
        ON UPDATE CASCADE ON DELETE NO ACTION,

    FOREIGN KEY (endereco_id) REFERENCES Endereco(id_endereco)
        ON UPDATE CASCADE ON DELETE SET NULL,

    FOREIGN KEY (alvo_id) REFERENCES Alvo_ID(id_alvo)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 8. Tabela de CPF 
CREATE TABLE Cpf (
    usuario_id INT,
    cpf CHAR(11) NOT NULL UNIQUE,

    PRIMARY KEY (usuario_id),

    FOREIGN KEY (usuario_id) REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 9. Tabela de CNPJ
CREATE TABLE Cnpj (
    usuario_id INT,
    cnpj CHAR(14) NOT NULL UNIQUE,

    PRIMARY KEY (usuario_id),

    FOREIGN KEY (usuario_id) REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 10. Tabela de Categorias de Itens
CREATE TABLE Categoria_tipo (
    id_categoria INT AUTO_INCREMENT,
    tipo_categoria VARCHAR(50) NOT NULL UNIQUE, -- Ferramentas, eletrônicos, etc.

    PRIMARY KEY (id_categoria)
);

-- 11. Tabela de Estados de Conservação
CREATE TABLE Estado_tipo (
    id_estado INT AUTO_INCREMENT,
    tipo_estado VARCHAR(50) NOT NULL UNIQUE, -- Novo, usado, seminovo

    PRIMARY KEY (id_estado)
);

-- 12. Tabela de Disponibilidades de Itens
CREATE TABLE Status_tipo (
    id_status INT AUTO_INCREMENT,
    tipo_status VARCHAR(50) NOT NULL UNIQUE, -- Disponível, Não disponível (doado), Em uso (emprestado/alugado), Em manutenção

    PRIMARY KEY (id_status)
);

-- 13. Tabela de Itens
CREATE TABLE Item (
    id_item INT AUTO_INCREMENT,
    dono_id INT,
    nome_item VARCHAR(100) NOT NULL,
    categoria INT NOT NULL,
    status_item INT NOT NULL, 
    descricao TEXT,
    estado_conservacao INT NOT NULL,

    alvo_id INT NOT NULL UNIQUE, -- Para denúncias

    PRIMARY KEY (id_item),

    FOREIGN KEY (categoria) REFERENCES Categoria_tipo(id_categoria)
        ON UPDATE CASCADE ON DELETE NO ACTION,

    FOREIGN KEY (dono_id) REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE,

    FOREIGN KEY (status_item) REFERENCES Status_tipo(id_status)
        ON UPDATE CASCADE ON DELETE NO ACTION,

    FOREIGN KEY (estado_conservacao) REFERENCES Estado_tipo(id_estado)
        ON UPDATE CASCADE ON DELETE NO ACTION,

    FOREIGN KEY (alvo_id) REFERENCES Alvo_ID(id_alvo)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 14. Tabela de Fotos de Itens
CREATE TABLE Foto_item (
    foto_id INT,
    item_id INT,

    PRIMARY KEY (foto_id, item_id),

    FOREIGN KEY (foto_id) REFERENCES Foto(id_foto)
        ON UPDATE CASCADE ON DELETE CASCADE,

    FOREIGN KEY (item_id) REFERENCES Item(id_item)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 15. Tabela de Manutenção
CREATE TABLE Manutencao (
    id_manutencao INT AUTO_INCREMENT,
    item_id INT NOT NULL,
    data_inicio_manutencao DATE NOT NULL,
    data_fim_manutencao DATE,

    PRIMARY KEY (id_manutencao),

    FOREIGN KEY (item_id) REFERENCES Item(id_item)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 16. Tabela de Mensagens (Chat)
CREATE TABLE Mensagem (
    hash_mensagem CHAR(36), -- UUID
    item_id INT NOT NULL,
    remetente_id INT,
    destinatario_id INT,
    texto_mensagem TEXT NOT NULL,
    horario_mensagem TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    alvo_id INT NOT NULL UNIQUE, -- Para denúncias

    PRIMARY KEY (hash_mensagem),

    FOREIGN KEY (item_id) REFERENCES Item(id_item)
        ON UPDATE CASCADE ON DELETE CASCADE,

    FOREIGN KEY (remetente_id) REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE SET NULL,

    FOREIGN KEY (destinatario_id) REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE SET NULL,

    FOREIGN KEY (alvo_id) REFERENCES Alvo_ID(id_alvo)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 17. Tabela de Pontos de Coleta
CREATE TABLE Ponto_coleta (
    id_coleta INT AUTO_INCREMENT,
    nome_coleta VARCHAR(100) NOT NULL UNIQUE,
    endereco_coleta INT NOT NULL,

    PRIMARY KEY (id_coleta),

    FOREIGN KEY (endereco_coleta) REFERENCES Endereco(id_endereco)
        ON UPDATE CASCADE ON DELETE NO ACTION
);

-- 18. Tabela de Tipos de Transação
CREATE TABLE Transacao_tipo (
    id_transacao_tipo INT,
    tipo_transacao VARCHAR(40) NOT NULL UNIQUE,

    PRIMARY KEY (id_transacao_tipo)
);

-- 19. Tabela de Transações
CREATE TABLE Transacao (
    id_transacao INT AUTO_INCREMENT,
    item_id INT NOT NULL,
    comprador_id INT,
    coleta_id INT,
    tipo_transacao INT NOT NULL,
    data_transacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_coleta TIMESTAMP,

    alvo_id INT NOT NULL UNIQUE, -- Para denúncias

    PRIMARY KEY (id_transacao),

    FOREIGN KEY (item_id) REFERENCES Item(id_item)
        ON UPDATE CASCADE ON DELETE CASCADE,

    FOREIGN KEY (comprador_id) REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE,

    FOREIGN KEY (coleta_id) REFERENCES Ponto_coleta(id_coleta)
        ON UPDATE CASCADE ON DELETE SET NULL,

    FOREIGN KEY (tipo_transacao) REFERENCES Transacao_tipo(id_transacao_tipo)
        ON UPDATE CASCADE ON DELETE NO ACTION,

    FOREIGN KEY (alvo_id) REFERENCES Alvo_ID(id_alvo)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 20. Tabela de Transações de Aluguel
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

-- 21. Tabela de Transações de Empréstimo
CREATE TABLE Emprestimo (
    transacao_id INT,
    prev_devolucao DATE NOT NULL,
    update_date DATE, -- Gabriel: caso a previsão de devolução mude
    data_devolucao DATE,

    PRIMARY KEY (transacao_id),

    FOREIGN KEY (transacao_id) REFERENCES Transacao(id_transacao)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 22. Tabela de Transações de Venda
CREATE TABLE Venda (
    transacao_id INT,
    preco DECIMAL(10, 2) NOT NULL,

    PRIMARY KEY (transacao_id),

    FOREIGN KEY (transacao_id) REFERENCES Transacao(id_transacao)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 23. Tabela de Avaliações
CREATE TABLE Avaliacao (
    transacao_id INT,
    avaliador_id INT,
    avaliado_id INT,
    nota INT CHECK (nota BETWEEN 0 AND 10),
    avaliacao TEXT, -- Gabriel: pode ser nula?

    alvo_id INT NOT NULL UNIQUE, -- Para denúncias

    PRIMARY KEY (transacao_id, avaliado_id),

    FOREIGN KEY (transacao_id) REFERENCES Transacao(id_transacao)
        ON UPDATE CASCADE ON DELETE CASCADE,

    FOREIGN KEY (avaliador_id) REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE SET NULL,

    FOREIGN KEY (avaliado_id) REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE,

    FOREIGN KEY (alvo_id) REFERENCES Alvo_ID(id_alvo)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 24. Tabela de Métodos de Pagamento
CREATE TABLE Metodo_pagamento_tipo (
    id_metodo_pagamento INT,
    nome_metodo_pagamento VARCHAR(40) NOT NULL UNIQUE,

    PRIMARY KEY (id_metodo_pagamento)
);

-- 25. Tabela de Status de Pagamento
CREATE TABLE Status_pagamento_tipo (
    id_status_pagamento INT,
    nome_status_pagamento VARCHAR(40) NOT NULL UNIQUE,

    PRIMARY KEY (id_status_pagamento)
);

-- 26. Tabela de Pagamentos
CREATE TABLE Pagamento (
    id_pagamento INT AUTO_INCREMENT,
    transacao_id INT NOT NULL,
    metodo_pagamento INT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    status_pagamento INT,
    data_pagamento TIMESTAMP,
    id_gateway_externo VARCHAR(100),

    PRIMARY KEY (id_pagamento),

    FOREIGN KEY (transacao_id) REFERENCES Transacao(id_transacao)
        ON UPDATE CASCADE ON DELETE CASCADE,

    FOREIGN KEY (metodo_pagamento) REFERENCES Metodo_pagamento_tipo(id_metodo_pagamento)
        ON UPDATE CASCADE ON DELETE NO ACTION,

    FOREIGN KEY (status_pagamento) REFERENCES Status_pagamento_tipo(id_status_pagamento)
        ON UPDATE CASCADE ON DELETE NO ACTION
);

-- 27. Tabela de Estados de Denúncia
CREATE TABLE Denuncia_estado (
    id_denuncia_estado INT,
    denuncia_estado VARCHAR(40),

    PRIMARY KEY (id_denuncia_estado)
);

-- 28. Tabela de Denúncias
CREATE TABLE Denuncia (
    id_denuncia INT AUTO_INCREMENT,
    denuncia_denunciador_id INT NOT NULL,
    denuncia_alvo_id INT NOT NULL,
    denuncia_conteudo TINYTEXT NOT NULL,
    denuncia_data DATE NOT NULL,
    denuncia_estado INT NOT NULL,
    denuncia_responsavel INT,

    PRIMARY KEY (id_denuncia),

    FOREIGN KEY (denuncia_denunciador_id) REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE,

    FOREIGN KEY (denuncia_alvo_id) REFERENCES Alvo_ID(id_alvo)
        ON UPDATE CASCADE ON DELETE CASCADE,
   
    FOREIGN KEY (denuncia_estado) REFERENCES Denuncia_estado(id_denuncia_estado)
        ON UPDATE CASCADE ON DELETE NO ACTION,

    FOREIGN KEY (denuncia_responsavel) REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE SET NULL

);

-- 02_seed
INSERT INTO Mensalidade_tipo (id_mensalidade, tipo_mensalidade) VALUES
(1, 'Sem mensalidade'),
(2, 'Básica'),
(3, 'Plus');

INSERT INTO TipoPessoa (id_tipo_pessoa, tipo, nome_tipo) VALUES 
(1, 'PF', 'Pessoa Física'),
(2, 'PJ', 'Pessoa Jurídica');

INSERT INTO Permissao (id_permissao, nome_permissao) VALUES
(1, 'Conta inativa'),
(2, 'Conta ativa'),
(3,'Conta de moderação'),
(4,'Conta de administração'),
(5,'Conta banida');

INSERT INTO Estado_tipo (id_estado, tipo_estado) VALUES
(1, 'Novo'),
(2, 'Seminovo'),
(3, 'Usado');

INSERT INTO Status_tipo (id_status, tipo_status) VALUES
(1, 'Disponível'),
(2, 'Indisponível'),
(3, 'Em uso'),
(4, 'Em manutenção');

INSERT INTO Categoria_tipo (tipo_categoria) VALUES
('Ferramentas'),
('Eletrônicos'),
('Livros'),
('Esportes'),
('Móveis'),
('Eletrodomésticos'),
('Jardim'),
('Música'),
('Brinquedos'),
('Roupas'),
('Automotivo'),
('Informática'),
('Cozinha'),
('Decoração'),
('Instrumentos Musicais'),
('Filmes e Séries'),
('Jogos'),
('Camping'),
('Fotografia'),
('Artesanato');

INSERT INTO Metodo_pagamento_tipo (id_metodo_pagamento, nome_metodo_pagamento) VALUES
(1, 'Cartão de Crédito'),
(2, 'Cartão de Débito'),
(3, 'Boleto Bancário'),
(4, 'Pix'),
(5, 'Transferência Bancária');

INSERT INTO Status_pagamento_tipo (id_status_pagamento, nome_status_pagamento) VALUES
(1, 'Pendente'),
(2, 'Pago'),
(3, 'Cancelado'),
(4, 'Reembolsado');

INSERT INTO Denuncia_estado (id_denuncia_estado, denuncia_estado) VALUES
(1, 'Aberta'),
(2, 'Tramitando'),
(3, 'Cancelada - errada'),
(4, 'Cancelada - falsa'),
(0, 'Fechada');

INSERT INTO Transacao_tipo (id_transacao_tipo, tipo_transacao) VALUES
(1, 'Doação'),
(2, 'Aluguel'),
(3, 'Empréstimo'),
(4, 'Venda');

DROP ROLE IF EXISTS admin, moderador, user_app;

CREATE ROLE admin;
CREATE ROLE moderador;
CREATE ROLE user_app;

-- Admin
GRANT ALL PRIVILEGES ON ECOSHARE.* TO admin;

-- Moderador
GRANT SELECT, UPDATE, DELETE ON ECOSHARE.Item TO moderador;
GRANT SELECT, UPDATE ON ECOSHARE.Usuario TO moderador;

GRANT SELECT, DELETE ON ECOSHARE.Mensagem TO moderador;
GRANT SELECT, DELETE ON ECOSHARE.Avaliacao TO moderador;
GRANT SELECT, DELETE ON ECOSHARE.Denuncia TO moderador;
GRANT SELECT, DELETE ON ECOSHARE.Foto TO moderador;
GRANT SELECT, DELETE ON ECOSHARE.Foto_item TO moderador;

GRANT SELECT ON ECOSHARE.Transacao TO moderador;
GRANT SELECT ON ECOSHARE.Aluguel TO moderador;
GRANT SELECT ON ECOSHARE.Emprestimo TO moderador;
GRANT SELECT ON ECOSHARE.Venda TO moderador;

-- Usuário
GRANT SELECT ON ECOSHARE.* TO user_app;

GRANT INSERT ON ECOSHARE.Transacao TO user_app;
GRANT INSERT ON ECOSHARE.Aluguel TO user_app;
GRANT INSERT ON ECOSHARE.Emprestimo TO user_app;
GRANT INSERT ON ECOSHARE.Venda TO user_app;

GRANT INSERT ON ECOSHARE.Mensagem TO user_app;
GRANT INSERT ON ECOSHARE.Avaliacao TO user_app;
GRANT INSERT ON ECOSHARE.Denuncia TO user_app;

GRANT UPDATE ON ECOSHARE.Item TO user_app;

-- Criação de usuários e atribuição de papéis
DROP USER IF EXISTS 'app_admin'@'localhost', 'app_mod', 'app_user';

CREATE USER 'app_admin'@'localhost' IDENTIFIED BY 'senha1';
CREATE USER 'app_mod' IDENTIFIED BY 'senha2';
CREATE USER 'app_user' IDENTIFIED BY 'senha3';

GRANT admin TO 'app_admin'@'localhost';
GRANT moderador TO 'app_mod';
GRANT user_app TO 'app_user';

SET DEFAULT ROLE admin TO 'app_admin'@'localhost';
SET DEFAULT ROLE moderador TO 'app_mod';
SET DEFAULT ROLE user_app TO 'app_user';

-- 03_views
-- 1. View da Média da Avaliação por Usuário
CREATE VIEW Media_avaliacao AS
SELECT
    a.avaliado_id AS 'ID do Usuário',
    u.nome_usuario AS 'Nome do Usuário',
    AVG(a.nota) AS 'Média de Avaliações',
    COUNT(*) AS 'Quantidade de Avaliações'
FROM
    Avaliacao a
JOIN
    Usuario u ON a.avaliado_id = u.id_usuario
GROUP BY
    a.avaliado_id, u.nome_usuario;

-- 2. View de Pessoas Físicas com CPF
CREATE VIEW Pessoa_fisica AS
SELECT
    u.id_usuario AS 'ID do Usuário',
    u.nome_usuario AS 'Nome do Pessoa Física',
    c.cpf AS 'Número do CPF',
    u.email AS 'Email',
    m.tipo_mensalidade AS 'Tipo de Mensalidade',
    u.saldo AS 'Saldo',
    u.data_nascimento AS 'Data de Nascimento',
    e.cidade AS 'Município',
    e.estado AS 'Estado'
FROM
    Usuario u
JOIN
    Mensalidade_tipo m ON u.mensalidade_id = m.id_mensalidade
JOIN
    Cpf c ON u.id_usuario = c.usuario_id
JOIN
    Endereco e ON u.endereco_id = e.id_endereco
WHERE
    u.tipo_pessoa = 1;

-- 3. View de Pessoas Jurídicas com CNPJ
CREATE VIEW Pessoa_juridica AS
SELECT
    u.id_usuario AS 'ID do Usuário',
    u.nome_usuario AS 'Nome da Pessoa Jurídica',
    cj.cnpj AS 'Número do CNPJ',
    u.email AS 'Email',
    m.tipo_mensalidade AS 'Tipo de Mensalidade',
    u.saldo AS 'Saldo',
    e.cidade AS 'Município',
    e.estado AS 'Estado'
FROM
    Usuario u
JOIN
    Mensalidade_tipo m ON u.mensalidade_id = m.id_mensalidade
JOIN
    Cnpj cj ON u.id_usuario = cj.usuario_id
JOIN
    Endereco e ON u.endereco_id = e.id_endereco
WHERE
    u.tipo_pessoa = 2;

-- 4. View de Itens Disponíveis
CREATE VIEW Item_disponivel AS
SELECT
    i.nome_item AS 'Nome do Item',
    i.descricao AS 'Descrição',
    c.tipo_categoria AS 'Categoria',
    e.tipo_estado AS 'Estado de Conservação'
FROM
    Item i
JOIN
    Estado_tipo e ON i.estado_conservacao = e.id_estado
LEFT JOIN
    Categoria_tipo c ON i.categoria = c.id_categoria
WHERE   
    i.status_item = (SELECT id_status FROM Status_tipo WHERE tipo_status = 'Disponível');


-- 5. View de Itens por Categoria
CREATE VIEW Item_por_categoria AS
SELECT
    c.tipo_categoria AS 'Categoria',
    COUNT(*) AS 'Total de Itens',
    SUM(s.tipo_status = 'Disponível') AS 'Itens Disponíveis',
    SUM(s.tipo_status = 'Indisponível') AS 'Itens Indisponíveis',
    SUM(s.tipo_status = 'Em Uso') AS 'Itens em Uso',
    SUM(s.tipo_status = 'Em Manutenção') AS 'Itens em Manutenção'
FROM 
    Item i
JOIN 
    Categoria_tipo c ON i.categoria = c.id_categoria
JOIN 
    Status_tipo s ON i.status_item = s.id_status
GROUP BY 
    c.tipo_categoria;

-- 6. View de Itens por Estado de Conservação
CREATE VIEW Item_por_estado AS
SELECT
    e.tipo_estado AS 'Estado de Conservação',
    COUNT(i.id_item) AS 'Total de Itens'
FROM
    Item i
JOIN
    Estado_tipo e ON i.estado_conservacao = e.id_estado
GROUP BY
    e.tipo_estado;

-- 7. View de Itens por Usuário
CREATE VIEW Item_por_usuario AS
SELECT
    u.nome_usuario AS 'Nome do Usuário',
    COUNT(i.id_item) AS 'Total de Itens'
FROM
    Item i
JOIN
    Usuario u ON i.dono_id = u.id_usuario
GROUP BY
    u.nome_usuario;

-- 8. View de Transações por Tipo
CREATE VIEW Transacao_por_tipo AS
SELECT
    tt.tipo_transacao AS tipo_transacao,
    COUNT(t.id_transacao) AS total_transacoes
FROM
    Transacao t
INNER JOIN 
    Transacao_tipo tt ON t.tipo_transacao = tt.id_transacao_tipo
GROUP BY
    tt.tipo_transacao;

-- 9. View de Itens em Manutenção
CREATE VIEW Item_em_manutencao AS
SELECT
    i.id_item AS 'ID do Item',
    i.nome_item AS 'Nome do Item',
    u.nome_usuario AS 'Dono do Item',
    c.tipo_categoria AS 'Categoria',
    i.descricao AS 'Descrição',
    e.tipo_estado AS 'Estado de Conservação',
    m.data_inicio_manutencao AS 'Data de Entrada em Manutenção',
    m.data_fim_manutencao AS 'Data de Saída da Manutenção'
FROM
    Item i
JOIN
    Usuario u ON i.dono_id = u.id_usuario
JOIN
    Manutencao m ON i.id_item = m.item_id
JOIN
    Estado_tipo e ON i.estado_conservacao = e.id_estado
JOIN
    Categoria_tipo c ON i.categoria = c.id_categoria
WHERE
    m.data_fim_manutencao IS NULL OR m.data_fim_manutencao > CURRENT_DATE;

-- 10. View de Itens mais Populares (mais transacionados)
CREATE VIEW Item_popular AS
SELECT
    i.nome_item AS 'Nome do Item',
    COUNT(t.id_transacao) AS 'Total de Transações'
FROM
    Item i
JOIN
    Transacao t ON i.id_item = t.item_id
GROUP BY
    i.nome_item
ORDER BY
    'Total de Transações' DESC
LIMIT 10;

-- 11. Denuncias mais recentes
CREATE VIEW Ultimas_denuncias AS
SELECT
    d.id_denuncia AS 'ID da denúncia',
    d.denuncia_data AS 'Data da denúncia',
    d.denuncia_denunciador_id AS 'ID do denunciador',
    d.denuncia_alvo_id AS 'ID do objeto denunciado',
    alvo.tipo_objeto AS 'Tipo do objeto denunciado',
    d.denuncia_conteudo AS 'Texto da denúncia',
    de.denuncia_estado AS 'Estado da denuncia'
FROM
    Denuncia as d
JOIN 
    Alvo_ID as alvo
        ON d.denuncia_alvo_id = alvo.id_alvo  
JOIN
    Denuncia_estado as de
        ON d.denuncia_estado = de.id_denuncia_estado
ORDER BY 
    'Data da denúncia' DESC;

-- 12. Denúncias mais antigas ainda em aberto 
CREATE VIEW Denuncias_abertas_mais_antigas AS
SELECT
    d.id_denuncia AS 'ID da denúncia',
    d.denuncia_data AS 'Data da denúncia',
    d.denuncia_alvo_id AS 'ID do objeto denunciado',
    alvo.tipo_objeto AS 'Tipo do objeto denunciado',
    d.denuncia_conteudo AS 'Texto da denúncia'
FROM
    Denuncia AS d
JOIN 
    Alvo_ID AS alvo
        ON d.denuncia_alvo_id = alvo.id_alvo
JOIN
    Denuncia_estado AS de 
        ON d.denuncia_estado = de.id_denuncia_estado
WHERE
    de.denuncia_estado = 'Aberto'
ORDER BY
    'Data da denúncia' ASC;

-- 13. Contagem de denúncias por estado
CREATE VIEW Denuncias_por_estado AS
SELECT
    de.denuncia_estado AS 'Estado da denúncia',
    COUNT(*) AS 'Número de denúncias'
FROM
    Denuncia AS d
JOIN
    Denuncia_estado AS de
        ON d.denuncia_estado = de.id_denuncia_estado
GROUP BY
    de.denuncia_estado

-- 04_triggers
DELIMITER //

-- Ao iniciar manutenção -> Muda item para 4 (Em manutenção)
CREATE TRIGGER trg_inicio_manutencao
AFTER INSERT ON Manutencao
FOR EACH ROW
BEGIN
    -- Verifica se data_fim_manutencao está NULL antes de mudar o status
    IF NEW.data_fim_manutencao IS NULL THEN
        UPDATE Item
        SET status_item = 4
        WHERE id_item = NEW.item_id;
    END IF;
END;
//

-- Ao finalizar manutenção (data_fim preenchida) -> Muda item para 1 (Disponível)
CREATE TRIGGER trg_fim_manutencao
AFTER UPDATE ON Manutencao
FOR EACH ROW
BEGIN
    IF OLD.data_fim_manutencao IS NULL AND NEW.data_fim_manutencao IS NOT NULL THEN
        UPDATE Item
        SET status_item = 1
        WHERE id_item = NEW.item_id;
    END IF;
END;
//

-- Valida disponibilidade e impede autonegociação
CREATE TRIGGER trg_valida_transacao
BEFORE INSERT ON Transacao
FOR EACH ROW
BEGIN
    DECLARE estado_atual INT;
    DECLARE id_dono INT;
    
    SELECT status_item, dono_id INTO estado_atual, id_dono 
    FROM Item 
    WHERE id_item = NEW.item_id;
    
    -- Verifica se o item está Disponível (1)
    IF estado_atual != 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Operação negada: Item indisponível.';
    END IF;

    -- Impede que o dono compre/alugue de si mesmo
    IF id_dono = NEW.comprador_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro: Proprietário não pode transacionar o próprio item.';
    END IF;
END;
//

-- Atualiza o saldo automaticamente
CREATE TRIGGER trg_atualiza_saldo_vendedor
AFTER UPDATE ON Pagamento
FOR EACH ROW
BEGIN
    DECLARE v_dono_id INT;

    -- Verifica se o status mudou para 'Pago' (2)
    IF OLD.status_pagamento != 2 AND NEW.status_pagamento = 2 THEN
        -- Localiza o dono do item através da transação
        SELECT i.dono_id INTO v_dono_id
        FROM Transacao t
        JOIN Item i ON t.item_id = i.id_item
        WHERE t.id_transacao = NEW.transacao_id;

        -- Adiciona o valor ao saldo do dono
        UPDATE Usuario
        SET saldo = saldo + NEW.valor
        WHERE id_usuario = v_dono_id;
    END IF;
END;
//

-- Validação para CPF
CREATE TRIGGER trg_valida_insercao_cpf
BEFORE INSERT ON Cpf
FOR EACH ROW
BEGIN
    DECLARE v_tipo INT;
    SELECT tipo_pessoa INTO v_tipo FROM Usuario WHERE id_usuario = NEW.usuario_id;
    
    IF v_tipo != 1 THEN -- 1 é PF
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro: Usuário deve ser Pessoa Física para possuir CPF.';
    END IF;
END;
//

-- Validação para CNPJ
CREATE TRIGGER trg_valida_insercao_cnpj
BEFORE INSERT ON Cnpj
FOR EACH ROW
BEGIN
    DECLARE v_tipo INT;
    SELECT tipo_pessoa INTO v_tipo FROM Usuario WHERE id_usuario = NEW.usuario_id;
    
    IF v_tipo != 2 THEN -- 2 é PJ
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro: Usuário deve ser Pessoa Jurídica para possuir CNPJ.';
    END IF;
END;
//

-- Validação para atualização do tipo de pessoa
CREATE TRIGGER trg_valida_update_tipo_pessoa
BEFORE UPDATE ON Usuario
FOR EACH ROW
BEGIN
    IF OLD.tipo_pessoa != NEW.tipo_pessoa THEN
       IF EXISTS (SELECT 1 FROM Cpf WHERE usuario_id = NEW.id_usuario) THEN
            SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Erro: Não é possível alterar tipo de pessoa com CPF associado.';
        END IF;
        
        IF EXISTS (SELECT 1 FROM Cnpj WHERE usuario_id = NEW.id_usuario) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Erro: Não é possível alterar tipo de pessoa com CNPJ associado.';
        END IF;
    END IF;
 END;
//

-- Validação de idade do usuário (apenas se data_nascimento for um atributo de PF) - NA APRESENTAÇÃO!
-- CREATE TRIGGER trg_valida_idade_usuario
-- BEFORE INSERT ON Usuario
-- FOR EACH ROW
-- BEGIN
--     DECLARE idade INT;
--     SET idade = TIMESTAMPDIFF(YEAR, NEW.data_nascimento, CURDATE());
    
--     IF idade < 18 THEN
--         SIGNAL SQLSTATE '45000'
--         SET MESSAGE_TEXT = 'Erro: Usuário deve ter pelo menos 18 anos.';
--     END IF;
-- END;
-- //

-- Adição de ID de alvo a mensagens
CREATE TRIGGER add_id_alvo_msg
BEFORE INSERT ON Mensagem
FOR EACH ROW
BEGIN
    INSERT INTO Alvo_ID (tipo_objeto) VALUES ('Mensagem');
    SET NEW.alvo_id = LAST_INSERT_ID();
END; 
//

-- Adição de ID de alvo a avaliações
CREATE TRIGGER add_id_alvo_aval
BEFORE INSERT ON Avaliacao
FOR EACH ROW
BEGIN
    INSERT INTO Alvo_ID (tipo_objeto) VALUES ('Avaliação');
    SET NEW.alvo_id = LAST_INSERT_ID();
END;
//

-- Adição de ID de alvo a transações
CREATE TRIGGER add_id_alvo_trsc
BEFORE INSERT ON Transacao
FOR EACH ROW
BEGIN
    INSERT INTO Alvo_ID (tipo_objeto) VALUES ('Transação');
    SET NEW.alvo_id = LAST_INSERT_ID();
END;
//

-- Adição de ID de alvo a itens
CREATE TRIGGER add_id_alvo_item
BEFORE INSERT ON Item
FOR EACH ROW
BEGIN
    INSERT INTO Alvo_ID (tipo_objeto) VALUES ('Item');
    SET NEW.alvo_id = LAST_INSERT_ID();
END;
//

-- Adição de ID de alvo a usuários
CREATE TRIGGER add_id_alvo_user
BEFORE INSERT ON Usuario
FOR EACH ROW
BEGIN
    INSERT INTO Alvo_ID (tipo_objeto) VALUES ('Usuário');
    SET NEW.alvo_id = LAST_INSERT_ID();
END;
//

-- Trigger de delete em cascata para denúncias relacionadas a um item
CREATE TRIGGER trg_item_delete
BEFORE DELETE ON Item
FOR EACH ROW
BEGIN
    DELETE FROM Alvo_ID
    WHERE id_alvo = OLD.alvo_id;
END;
//

-- Trigger de delete em cascata para denúncias relacionadas a um usuário
CREATE TRIGGER trg_usuario_delete
BEFORE DELETE ON Usuario
FOR EACH ROW
BEGIN
    DELETE FROM Alvo_ID
    WHERE id_alvo = OLD.alvo_id;
END;
//

-- Trigger de delete em cascata para denúncias relacionadas a uma mensagem
CREATE TRIGGER trg_mensagem_delete
BEFORE DELETE ON Mensagem
FOR EACH ROW
BEGIN
    DELETE FROM Alvo_ID
    WHERE id_alvo = OLD.alvo_id;
END;
//

-- Trigger de delete em cascata para denúncias relacionadas a uma transação
CREATE TRIGGER trg_transacao_delete
BEFORE DELETE ON Transacao
FOR EACH ROW
BEGIN
    DELETE FROM Alvo_ID
    WHERE id_alvo = OLD.alvo_id;
END;
//

-- Trigger de delete em cascata para denúncias relacionadas a uma avaliação
CREATE TRIGGER trg_avaliacao_delete
BEFORE DELETE ON Avaliacao
FOR EACH ROW
BEGIN
    DELETE FROM Alvo_ID
    WHERE id_alvo = OLD.alvo_id;
END;
//

-- Trigger para impedir exclusão de alvo com denúncias ativas
CREATE TRIGGER trg_alvo_delete
BEFORE DELETE ON Alvo_ID
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Denuncia
        WHERE denuncia_alvo_id = OLD.id_alvo
          AND denuncia_estado IN (1,2)
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Objeto possui denúncia ativa.';
    END IF;
END;
//

-- Trigger para impedir deleção de item se a última transação dele tiver menos que 90 dias
CREATE TRIGGER trg_item_delete_90dias
BEFORE DELETE ON Item
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Transacao
        WHERE item_id = OLD.id_item
          AND DATEDIFF(CURDATE(), data_transacao) < 90
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Item possui transação recente (menos de 90 dias).';
    END IF;
END;
//

-- Triggers para impedir deleção de usuário se a última transação dele, seja como vendedor ou comprador, tiver menos que 90 dias
CREATE TRIGGER trg_usuario_delete_90dias_comprador
BEFORE DELETE ON Usuario
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Transacao
        WHERE comprador_id = OLD.id_usuario
          AND DATEDIFF(CURDATE(), data_transacao) < 90
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Usuário possui transação recente (menos de 90 dias).';
    END IF;
END;
//

CREATE TRIGGER trg_usuario_delete_90dias_vendedor
BEFORE DELETE ON Usuario
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Transacao t
        JOIN Item i ON t.item_id = i.id_item
        WHERE i.dono_id = OLD.id_usuario
          AND DATEDIFF(CURDATE(), t.data_transacao) < 90
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Usuário possui transação recente (menos de 90 dias).';
    END IF;
END;
//

-- Triggers para impedir atualização de item ou usuário se a última transação tiver menos que 5 dias
CREATE TRIGGER trg_item_update_5dias
BEFORE UPDATE ON Item
FOR EACH ROW
BEGIN
    IF @skip_trg_item_update_5dias IS NULL THEN
        IF EXISTS(
            SELECT 1
            FROM Transacao
            WHERE item_id = OLD.id_item
              AND DATEDIFF(CURDATE(), data_transacao) < 5
        ) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Item possui transação recente (menos de 5 dias).';
        END IF;
    END IF;
END;
//

CREATE TRIGGER trg_usuario_update_5dias_comprador
BEFORE UPDATE ON Usuario
FOR EACH ROW
BEGIN
    IF EXISTS(
        SELECT 1
        FROM Transacao
        WHERE comprador_id = OLD.id_usuario
          AND DATEDIFF(CURDATE(), data_transacao) < 5
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Usuário possui transação recente (menos de 5 dias).';
    END IF;
END;
//

CREATE TRIGGER trg_usuario_update_5dias_vendedor
BEFORE UPDATE ON Usuario
FOR EACH ROW
BEGIN
    IF EXISTS(
        SELECT 1
        FROM Transacao t
        JOIN Item i ON t.item_id = i.id_item
        WHERE i.dono_id = OLD.id_usuario
          AND DATEDIFF(CURDATE(), t.data_transacao) < 5
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Usuário possui transação recente (menos de 5 dias).';
    END IF;
END;
//

DELIMITER ;

-- 05_procedures
-- 1. Transação de criação de usuário
DELIMITER $$

CREATE PROCEDURE criar_usuario (
    IN p_nome VARCHAR(100),
    IN p_email VARCHAR(100),
    IN p_hash_senha VARCHAR(255),
    IN p_data_nascimento DATE,
    IN p_tipo_pessoa INT,
    IN p_doc VARCHAR(14),
    IN p_mensalidade INT,
    IN p_permissao INT
)
BEGIN
    DECLARE v_usuario_id INT;

    INSERT INTO Usuario (
        mensalidade_id,
        nivel_permissao,
        nome_usuario,
        email,
        tipo_pessoa,
        hash_senha,
        data_nascimento
    )
    VALUES (
        p_mensalidade,
        p_permissao,
        p_nome,
        p_email,
        p_tipo_pessoa,
        p_hash_senha,
        p_data_nascimento
    );

    SET v_usuario_id = LAST_INSERT_ID();

    IF p_tipo_pessoa = 1 THEN
        INSERT INTO Cpf(usuario_id, cpf)
        VALUES (v_usuario_id, p_doc);
    ELSE
        INSERT INTO Cnpj(usuario_id, cnpj)
        VALUES (v_usuario_id, p_doc);
    END IF;
END$$

DELIMITER ;

-- 2. Transação de criação de item
DELIMITER $$

CREATE PROCEDURE cadastrar_item (
    IN p_dono INT,
    IN p_nome VARCHAR(100),
    IN p_categoria INT,
    IN p_status INT,
    IN p_descricao TEXT,
    IN p_estado INT
)
BEGIN
    INSERT INTO Item (
        dono_id,
        nome_item,
        categoria,
        status_item,
        descricao,
        estado_conservacao
    )
    VALUES (
        p_dono,
        p_nome,
        p_categoria,
        p_status,
        p_descricao,
        p_estado
    );
END$$

DELIMITER ;

-- 3. Transação de criação de transação (compra, aluguel ou empréstimo)
DELIMITER $$

CREATE PROCEDURE criar_transacao (
    IN p_item INT,
    IN p_comprador INT,
    IN p_coleta INT,
    IN p_tipo INT,
    IN p_preco DECIMAL(10,2),
    IN p_prev_devolucao DATE
)
BEGIN
    DECLARE v_transacao_id INT;

    INSERT INTO Transacao (
        item_id,
        comprador_id,
        coleta_id,
        tipo_transacao
    )
    VALUES (
        p_item,
        p_comprador,
        p_coleta,
        p_tipo
    );

    SET v_transacao_id = LAST_INSERT_ID();

    IF p_tipo = 1 THEN
        INSERT INTO Venda (
            transacao_id,
            preco
        )
        VALUES (
            v_transacao_id,
            p_preco
        );

    ELSEIF p_tipo = 2 THEN
        INSERT INTO Emprestimo (
            transacao_id,
            prev_devolucao
        )
        VALUES (
            v_transacao_id,
            p_prev_devolucao
        );

    ELSEIF p_tipo = 3 THEN
        INSERT INTO Aluguel (
            transacao_id,
            prev_devolucao,
            preco
        )
        VALUES (
            v_transacao_id,
            p_prev_devolucao,
            p_preco
        );
    END IF;

END$$

DELIMITER ;

-- 4. Transação de criação de pagamento
DELIMITER $$

CREATE PROCEDURE registrar_pagamento (
    IN p_transacao INT,
    IN p_metodo INT,
    IN p_valor DECIMAL(10,2),
    IN p_status INT
)
BEGIN
    INSERT INTO Pagamento (
        transacao_id,
        metodo_pagamento,
        valor,
        status_pagamento,
        data_pagamento
    )
    VALUES (
        p_transacao,
        p_metodo,
        p_valor,
        p_status,
        CURRENT_TIMESTAMP
    );
END$$

DELIMITER ;

-- 5. Transação de devolução de item
DELIMITER $$

CREATE PROCEDURE registrar_devolucao (
    IN p_transacao INT,
    IN p_data DATE
)
BEGIN
    UPDATE Emprestimo
    SET data_devolucao = p_data
    WHERE transacao_id = p_transacao;

    UPDATE Aluguel
    SET data_devolucao = p_data
    WHERE transacao_id = p_transacao;

    UPDATE Item
    SET status_item = 1
    WHERE id_item = (
        SELECT item_id FROM Transacao WHERE id_transacao = p_transacao
    );
END$$

DELIMITER ;

-- 6. Transação de abertura de denúncia
DELIMITER $$

CREATE PROCEDURE abrir_denuncia (
    IN p_denunciador INT,
    IN p_tipo_objeto VARCHAR(40),
    IN p_conteudo TINYTEXT,
    IN p_estado INT
)
BEGIN
    DECLARE v_alvo INT;

    INSERT INTO Alvo_ID(tipo_objeto)
    VALUES (p_tipo_objeto);

    SET v_alvo = LAST_INSERT_ID();

    INSERT INTO Denuncia (
        denuncia_denunciador_id,
        denuncia_alvo_id,
        denuncia_conteudo,
        denuncia_data,
        denuncia_estado
    )
    VALUES (
        p_denunciador,
        v_alvo,
        p_conteudo,
        CURRENT_DATE,
        p_estado
    );
END$$

DELIMITER ;

-- 06_dados
USE ECOSHARE;

-- ============================================
-- 1. INSERIR 60 ENDEREÇOS
-- ============================================
INSERT INTO Endereco (cep, logradouro, numero, complemento, bairro, cidade, estado) VALUES
-- São Paulo (1-15)
('01310-100', 'Avenida Paulista', '1000', 'Apto 101', 'Bela Vista', 'São Paulo', 'SP'),
('01410-001', 'Rua Augusta', '500', 'Sala 201', 'Jardim Paulista', 'São Paulo', 'SP'),
('05407-002', 'Rua Cardeal Arcoverde', '2365', 'Apto 302', 'Pinheiros', 'São Paulo', 'SP'),
('04538-132', 'Rua Funchal', '129', NULL, 'Vila Olímpia', 'São Paulo', 'SP'),
('05012-000', 'Rua Turiassu', '1234', 'Casa 2', 'Perdizes', 'São Paulo', 'SP'),
('03110-020', 'Rua da Graça', '456', NULL, 'Brás', 'São Paulo', 'SP'),
('01501-000', 'Rua 25 de Março', '789', 'Loja 5', 'Centro', 'São Paulo', 'SP'),
('04711-130', 'Rua Natingui', '555', 'Apto 901', 'Vila Madalena', 'São Paulo', 'SP'),
('05426-000', 'Rua Artur de Azevedo', '123', NULL, 'Pinheiros', 'São Paulo', 'SP'),
('04560-002', 'Rua Pedroso Alvarenga', '1001', 'Sala 100', 'Itaim Bibi', 'São Paulo', 'SP'),
('04534-002', 'Avenida Brigadeiro Faria Lima', '3477', '12º andar', 'Itaim Bibi', 'São Paulo', 'SP'),
('01455-001', 'Alameda Santos', '2100', NULL, 'Cerqueira César', 'São Paulo', 'SP'),
('04547-004', 'Rua Joaquim Floriano', '72', 'Apto 1501', 'Itaim Bibi', 'São Paulo', 'SP'),
('05409-001', 'Rua Teodoro Sampaio', '1000', 'Sala 3', 'Pinheiros', 'São Paulo', 'SP'),
('04543-000', 'Rua Estados Unidos', '1638', NULL, 'Jardim Paulista', 'São Paulo', 'SP'),

-- Rio de Janeiro (16-25)
('20040-002', 'Rua do Ouvidor', '50', 'Sala 302', 'Centro', 'Rio de Janeiro', 'RJ'),
('22011-000', 'Rua Visconde de Pirajá', '550', 'Loja 10', 'Ipanema', 'Rio de Janeiro', 'RJ'),
('22411-000', 'Avenida Ataulfo de Paiva', '100', 'Apto 401', 'Leblon', 'Rio de Janeiro', 'RJ'),
('22290-000', 'Rua Garcia dÁvila', '80', NULL, 'Ipanema', 'Rio de Janeiro', 'RJ'),
('22250-040', 'Rua Aníbal de Mendonça', '35', 'Cobertura', 'Ipanema', 'Rio de Janeiro', 'RJ'),
('22061-000', 'Rua Barão da Torre', '200', 'Apto 701', 'Ipanema', 'Rio de Janeiro', 'RJ'),
('22070-000', 'Rua Vinícius de Moraes', '49', NULL, 'Ipanema', 'Rio de Janeiro', 'RJ'),
('22231-000', 'Rua Jangadeiros', '10', 'Sala 5', 'Ipanema', 'Rio de Janeiro', 'RJ'),
('22470-000', 'Rua General Urquiza', '300', 'Apto 202', 'Leblon', 'Rio de Janeiro', 'RJ'),
('22620-172', 'Avenida das Américas', '5000', 'Bloco 3', 'Barra da Tijuca', 'Rio de Janeiro', 'RJ'),

-- Belo Horizonte (26-35)
('30130-001', 'Rua da Bahia', '1234', NULL, 'Centro', 'Belo Horizonte', 'MG'),
('30140-071', 'Avenida do Contorno', '8000', 'Sala 801', 'Lourdes', 'Belo Horizonte', 'MG'),
('30350-540', 'Rua Cláudio Manoel', '100', 'Casa', 'Funcionários', 'Belo Horizonte', 'MG'),
('30170-010', 'Rua dos Inconfidentes', '900', 'Loja 2', 'Savassi', 'Belo Horizonte', 'MG'),
('30190-050', 'Rua Antônio de Albuquerque', '330', 'Apto 303', 'Funcionários', 'Belo Horizonte', 'MG'),
('30380-032', 'Rua Professor Moraes', '200', NULL, 'Funcionários', 'Belo Horizonte', 'MG'),
('30315-420', 'Rua Bernardo Guimarães', '1500', 'Sala 10', 'Funcionários', 'Belo Horizonte', 'MG'),
('30320-110', 'Rua Alagoas', '700', 'Apto 1001', 'Funcionários', 'Belo Horizonte', 'MG'),
('30130-170', 'Rua Espírito Santo', '450', NULL, 'Centro', 'Belo Horizonte', 'MG'),
('30140-070', 'Avenida Amazonas', '1200', 'Loja 15', 'Centro', 'Belo Horizonte', 'MG'),

-- Outras cidades (36-60)
('40010-010', 'Rua Chile', '23', 'Loja 5', 'Centro', 'Salvador', 'BA'),
('88015-200', 'Rua Felipe Schmidt', '345', NULL, 'Centro', 'Florianópolis', 'SC'),
('70070-100', 'SQS 102', 'Bloco A', 'Apto 504', 'Asa Sul', 'Brasília', 'DF'),
('80020-300', 'Rua 15 de Novembro', '789', 'Sobreloja', 'Centro', 'Curitiba', 'PR'),
('90010-000', 'Rua dos Andradas', '100', 'Sala 1001', 'Centro Histórico', 'Porto Alegre', 'RS'),
('29010-090', 'Rua São Miguel', '258', NULL, 'Centro', 'Vitória', 'ES'),
('57035-000', 'Rua do Comércio', '456', 'Loja 3', 'Centro', 'Maceió', 'AL'),
('79002-010', 'Rua 14 de Julho', '1234', 'Apto 302', 'Centro', 'Campo Grande', 'MS'),
('69005-000', 'Avenida Eduardo Ribeiro', '500', 'Sala 8', 'Centro', 'Manaus', 'AM'),
('64000-100', 'Rua Areolino de Abreu', '789', NULL, 'Centro', 'Teresina', 'PI'),
('49010-000', 'Rua Santa Luzia', '321', 'Loja 2', 'Centro', 'Aracaju', 'SE'),
('66010-000', 'Avenida Presidente Vargas', '1000', 'Apto 1501', 'Campina', 'Belém', 'PA'),
('58010-000', 'Rua Duque de Caxias', '456', NULL, 'Centro', 'João Pessoa', 'PB'),
('59010-000', 'Avenida Rio Branco', '500', 'Sala 302', 'Centro', 'Natal', 'RN'),
('57020-000', 'Rua do Sol', '123', 'Casa', 'Centro', 'Recife', 'PE'),
('69010-000', 'Rua 24 de Maio', '789', 'Loja 10', 'Centro', 'Cuiabá', 'MT'),
('77001-000', 'Quadra 101 Norte', '12', 'Apto 304', 'Plano Diretor Norte', 'Palmas', 'TO'),
('65010-000', 'Rua Grande', '456', NULL, 'Centro', 'São Luís', 'MA'),
('69900-000', 'Rua Epaminondas Jácome', '789', 'Sala 5', 'Centro', 'Rio Branco', 'AC'),
('76801-000', 'Avenida Calama', '1000', 'Apto 701', 'Centro', 'Porto Velho', 'RO'),
('69301-000', 'Avenida Ville Roy', '500', NULL, 'Centro', 'Boa Vista', 'RR'),
('59600-000', 'Rua Mossoró', '123', 'Loja 3', 'Centro', 'Mossoró', 'RN'),
('59114-000', 'Rua Professor Antônio Barreto', '456', 'Sala 10', 'Centro', 'Macapá', 'AP'),
('69980-000', 'Rua Floriano Peixoto', '789', NULL, 'Centro', 'Cruzeiro do Sul', 'AC');

-- ============================================
-- 2. INSERIR 50 USUÁRIOS (40 PF, 10 PJ)
-- ============================================
INSERT INTO Usuario (mensalidade_id, nivel_permissao, foto_perfil_id, nome_usuario, email, tipo_pessoa, hash_senha, data_nascimento, saldo, endereco_id) VALUES
-- Pessoas Físicas (1-40)
(1, 2, NULL, 'João Silva', 'joao.silva@email.com', 1, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '1985-05-15', 150.75, 1),
(2, 2, NULL, 'Maria Oliveira', 'maria.oliveira@email.com', 1, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '1990-08-22', 0.00, 2),
(3, 2, NULL, 'Carlos Santos', 'carlos.santos@email.com', 1, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '1978-11-30', 500.00, 3),
(1, 2, NULL, 'Ana Costa', 'ana.costa@email.com', 1, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '1995-03-10', 25.50, 4),
(2, 2, NULL, 'Pedro Lima', 'pedro.lima@email.com', 1, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '1982-07-18', 320.00, 5),
(1, 2, NULL, 'Fernanda Rocha', 'fernanda.rocha@email.com', 1, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '1992-04-25', 45.00, 6),
(3, 2, NULL, 'Ricardo Alves', 'ricardo.alves@email.com', 1, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '1988-12-05', 1200.00, 7),
(2, 2, NULL, 'Juliana Pereira', 'juliana.pereira@email.com', 1, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '1993-06-30', 85.75, 8),
(1, 2, NULL, 'Marcos Souza', 'marcos.souza@email.com', 1, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '1975-09-14', 210.50, 9),
(3, 2, NULL, 'Camila Martins', 'camila.martins@email.com', 1, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '1989-01-20', 650.25, 10),
(2, 2, NULL, 'Roberto Ferreira', 'roberto.ferreira@email.com', 1, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '1991-11-11', 90.00, 11),
(1, 2, NULL, 'Patrícia Gomes', 'patricia.gomes@email.com', 1, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '1996-07-08', 35.25, 12),
(3, 2, NULL, 'Lucas Rodrigues', 'lucas.rodrigues@email.com', 1, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '1984-02-19', 780.50, 13),
(2, 2, NULL, 'Amanda Silva', 'amanda.silva@email.com', 1, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '1997-05-22', 125.00, 14),
(1, 2, NULL, 'Rafael Costa', 'rafael.costa@email.com', 1, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '1994-09-03', 42.75, 15),
(3, 2, NULL, 'Beatriz Santos', 'beatriz.santos@email.com', 1, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '1987-12-15', 950.00, 16),
(2, 2, NULL, 'Daniel Oliveira', 'daniel.oliveira@email.com', 1, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '1990-03-28', 65.50, 17),
(1, 2, NULL, 'Tatiane Lima', 'tatiane.lima@email.com', 1, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '1993-08-10', 180.25, 18),
(3, 2, NULL, 'Bruno Almeida', 'bruno.almeida@email.com', 1, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '1986-01-05', 520.75, 19),
(2, 2, NULL, 'Vanessa Pereira', 'vanessa.pereira@email.com', 1, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '1995-11-18', 75.00, 20),
(1, 2, NULL, 'Gustavo Rocha', 'gustavo.rocha@email.com', 1, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '1981-06-12', 230.50, 21),
(3, 2, NULL, 'Isabela Martins', 'isabela.martins@email.com', 1, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '1989-04-07', 680.25, 22),
(2, 2, NULL, 'Leonardo Souza', 'leonardo.souza@email.com', 1, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '1992-02-14', 95.75, 23),
(1, 2, NULL, 'Mariana Ferreira', 'mariana.ferreira@email.com', 1, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '1998-10-30', 28.00, 24),
(3, 2, NULL, 'Thiago Gomes', 'thiago.gomes@email.com', 1, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '1983-07-25', 420.50, 25),
(2, 2, NULL, 'Carolina Rodrigues', 'carolina.rodrigues@email.com', 1, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '1991-09-19', 110.25, 26),
(1, 2, NULL, 'Eduardo Silva', 'eduardo.silva@email.com', 1, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '1987-03-02', 85.00, 27),
(3, 2, NULL, 'Larissa Costa', 'larissa.costa@email.com', 1, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '1994-12-08', 560.75, 28),
(2, 2, NULL, 'Fábio Santos', 'fabio.santos@email.com', 1, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '1980-05-17', 135.50, 29),
(1, 2, NULL, 'Natália Oliveira', 'natalia.oliveira@email.com', 1, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '1996-01-23', 47.25, 30),
(3, 2, NULL, 'Alexandre Lima', 'alexandre.lima@email.com', 1, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '1985-08-04', 720.00, 31),
(2, 2, NULL, 'Gabriela Almeida', 'gabriela.almeida@email.com', 1, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '1993-06-27', 92.75, 32),
(1, 2, NULL, 'André Pereira', 'andre.pereira@email.com', 1, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '1989-11-11', 250.00, 33),
(3, 2, NULL, 'Cláudia Rocha', 'claudia.rocha@email.com', 1, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '1990-02-14', 380.50, 34),
(2, 2, NULL, 'Renato Martins', 'renato.martins@email.com', 1, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '1982-10-09', 65.25, 35),
(1, 2, NULL, 'Aline Souza', 'aline.souza@email.com', 1, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '1997-07-21', 175.00, 36),
(3, 2, NULL, 'Paulo Ferreira', 'paulo.ferreira@email.com', 1, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '1984-04-18', 490.75, 37),
(2, 2, NULL, 'Simone Gomes', 'simone.gomes@email.com', 1, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '1991-03-06', 82.50, 38),
(1, 2, NULL, 'Maurício Rodrigues', 'mauricio.rodrigues@email.com', 1, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '1988-12-24', 310.25, 39),
(3, 2, NULL, 'Tânia Silva', 'tania.silva@email.com', 1, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '1995-09-15', 540.00, 40),

-- Pessoas Jurídicas (41-50)
(2, 2, NULL, 'Ferramax Ferramentas Ltda', 'contato@ferramax.com.br', 2, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '2010-01-05', 1000.00, 41),
(3, 2, NULL, 'TecnoGadget Store', 'vendas@tecnogadget.com', 2, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '2015-06-20', 750.25, 42),
(1, 2, NULL, 'Livraria Cultura Paulista', 'atendimento@livrariacultura.com', 2, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '2005-03-15', 320.50, 43),
(2, 2, NULL, 'Ciclomania Bicicletas', 'loja@ciclomania.com.br', 2, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '2012-08-22', 580.75, 44),
(3, 2, NULL, 'Móveis Nobres Design', 'vendas@moveisnobres.com', 2, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '2008-11-10', 1200.00, 45),
(1, 2, NULL, 'EletroCasa Utilitários', 'sac@eletrocasa.com.br', 2, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '2018-05-30', 450.25, 46),
(2, 2, NULL, 'Garden Center Plantas', 'contato@gardencenter.com', 2, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '2014-09-12', 680.00, 47),
(3, 2, NULL, 'Music House Instrumentos', 'info@musichouse.com.br', 2, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '2007-07-25', 890.50, 48),
(1, 2, NULL, 'Sport Life Equipamentos', 'vendas@sportlife.com', 2, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '2016-02-18', 375.75, 49),
(2, 2, NULL, 'Tech Solutions Informática', 'suporte@techsolutions.com.br', 2, '$2y$10$N7wY7bL1UQ6V5Z8M9X0pEe', '2019-04-05', 950.00, 50);

-- ============================================
-- 3. INSERIR CPFs (para os 40 primeiros usuários)
-- ============================================
INSERT INTO Cpf (usuario_id, cpf) VALUES
(1, '12345678901'), (2, '23456789012'), (3, '34567890123'), (4, '45678901234'), (5, '56789012345'),
(6, '67890123456'), (7, '78901234567'), (8, '89012345678'), (9, '90123456789'), (10, '01234567890'),
(11, '11223344556'), (12, '22334455667'), (13, '33445566778'), (14, '44556677889'), (15, '55667788990'),
(16, '66778899001'), (17, '77889900112'), (18, '88990011223'), (19, '99001122334'), (20, '00112233445'),
(21, '10293847566'), (22, '29384756017'), (23, '38475609128'), (24, '47560918239'), (25, '56091827340'),
(26, '61928374655'), (27, '72839465766'), (28, '83946576877'), (29, '94057687988'), (30, '05162738499'),
(31, '16273849500'), (32, '27384950611'), (33, '38495061722'), (34, '49506172833'), (35, '50617283944'),
(36, '61728394055'), (37, '72839405166'), (38, '83940516277'), (39, '94051627388'), (40, '05162738498');

-- ============================================
-- 4. INSERIR CNPJs (para os usuários 41-50)
-- ============================================
INSERT INTO Cnpj (usuario_id, cnpj) VALUES
(41, '12345678000195'), (42, '98765432000186'), (43, '45678901000123'), (44, '56789012000134'),
(45, '67890123000145'), (46, '78901234000156'), (47, '89012345000167'), (48, '90123456000178'),
(49, '01234567000189'), (50, '12345678900190');

-- ============================================
-- 5. INSERIR 30 ITENS
-- ============================================
INSERT INTO Item (dono_id, nome_item, categoria, status_item, descricao, estado_conservacao) VALUES
(1, 'Furadeira de Impacto 550W', 1, 1, 'Furadeira Bosch com 13mm, potente e em ótimo estado', 2),
(2, 'Kindle Paperwhite 10ª Geração', 2, 1, 'E-reader com iluminação embutida, tela antirreflexo', 1),
(3, 'Coleção Harry Potter Completa', 3, 1, '7 livros da série, edição brasileira, bem conservados', 3),
(4, 'Bicicleta Mountain Bike 21 Marchas', 4, 1, 'Bicicleta aro 29, suspensão dianteira, pouco uso', 2),
(41, 'Furadeira de Coluna Profissional', 1, 1, 'Furadeira industrial para trabalhos pesados', 2),
(42, 'Notebook Dell Inspiron 15', 2, 1, 'i5 10ª geração, 8GB RAM, 256GB SSD', 2),
(5, 'Guitarra Strato Fender', 8, 1, 'Guitarra elétrica cor sunburst, com capa e amplificador pequeno', 3),
(2, 'Mesa de Jantar 6 Lugares', 5, 1, 'Mesa de madeira maciça com 6 cadeiras', 2),
(6, 'Batedeira Planetária 5L', 6, 1, 'Batedeira com tigela de inox, 5 velocidades', 3),
(7, 'Kit de Ferramentas 100 Peças', 1, 1, 'Kit completo com chaves, alicates, chaves de fenda', 2),
(8, 'Violão Acústico Giannini', 8, 1, 'Violão folk, cordas de aço, case incluído', 2),
(9, 'Máquina de Lavar 8kg', 6, 1, 'Máquina de lavar roupas automática, pouco uso', 3),
(10, 'Skate Profissional', 4, 1, 'Skate completo, shape maple, rolamentos ABEC 7', 2),
(11, 'Jogo de Panelas Antiaderente', 13, 1, 'Conjunto com 5 panelas e 2 frigideiras', 2),
(12, 'Câmera DSLR Canon T7', 19, 1, 'Câmera com lente 18-55mm, pouquíssimo uso', 1),
(13, 'Tênis de Corrida Nike', 10, 1, 'Tênis modelo Air Max, tamanho 42, usado 2 vezes', 2),
(14, 'Liquidificador Turbo 2L', 6, 1, 'Liquidificador com 6 velocidades, jarra de vidro', 3),
(15, 'Jogo de Xadrez de Madeira', 9, 1, 'Peças de madeira entalhada, tabuleiro incluso', 2),
(16, 'Mochila de Camping 60L', 18, 1, 'Mochila impermeável, com estrutura interna', 2),
(17, 'Micro-ondas 20L', 6, 1, 'Micro-ondas com grill, pouco uso', 3),
(18, 'Tablet Samsung Galaxy Tab', 2, 1, 'Tablet 10.4 polegadas, 64GB, com capa', 2),
(19, 'Esteira Ergométrica', 4, 1, 'Esteira dobrável, 12 programas, display digital', 3),
(20, 'Kit de Pintura a Óleo', 20, 1, 'Kit com 12 cores, pincéis, cavalete e tela', 2),
(43, 'Enciclopédia Barsa Completa', 3, 1, 'Coleção completa 30 volumes, edição 2010', 3),
(44, 'Bicicleta Ergométrica', 4, 1, 'Bicicleta ergométrica com 8 níveis de resistência', 2),
(21, 'Caixa de Som Bluetooth JBL', 2, 1, 'Caixa de som à prova dágua, bateria de longa duração', 2),
(22, 'Ferro de Solda 60W', 1, 1, 'Ferro de solda com pontas intercambiáveis', 3),
(23, 'Máquina de Costura Singer', 20, 1, 'Máquina de costura básica, com acessórios', 2),
(24, 'Drone DJI Mini 2', 19, 1, 'Drone com câmera 4K, controle remoto, pouco uso', 1),
(25, 'Kit Churrasqueira Portátil', 18, 1, 'Churrasqueira a carvão dobrável, completa', 2);

-- ============================================
-- 6. INSERIR PONTOS DE COLETA (15 pontos)
-- ============================================
INSERT INTO Ponto_coleta (nome_coleta, endereco_coleta) VALUES
('EcoPoint Shopping Center', 1),
('Coleta Verde Parque', 3),
('Posto Sustentável Centro', 2),
('EcoHub Zona Sul', 4),
('EcoStation Barra', 20),
('Ponto Verde Savassi', 26),
('Coleta Ecológica Ipanema', 17),
('Posto Recicla Centro', 5),
('EcoBase Vila Madalena', 8),
('GreenPoint Jardins', 12),
('Estação Sustentável Pinheiros', 9),
('EcoPost Tijuca', 16),
('Recicla Mais Funcionários', 29),
('Ponto Verde Moema', 10),
('EcoHub Brooklin', 11);

-- ============================================
-- 7. INSERIR 25 TRANSAÇÕES
-- ============================================
INSERT INTO Transacao (item_id, comprador_id, coleta_id, tipo_transacao, data_transacao, data_coleta) VALUES
-- Doações (tipo 1)
(1, 2, 1, 1, '2024-01-15 10:30:00', '2024-01-16 14:00:00'),
(6, 3, 2, 1, '2024-02-10 09:15:00', '2024-02-11 11:00:00'),
(12, 8, 3, 1, '2024-03-05 16:20:00', '2024-03-06 10:30:00'),
(19, 12, 4, 1, '2024-04-12 14:45:00', '2024-04-13 15:15:00'),
(23, 18, 5, 1, '2024-05-20 11:10:00', '2024-05-21 09:45:00'),

-- Aluguéis (tipo 2)
(2, 4, 6, 2, '2026-01-20 15:30:00', '2026-01-24 12:00:00'),
(4, 6, 7, 2, '2024-02-15 13:20:00', '2024-02-16 14:30:00'),
(7, 9, 8, 2, '2025-03-10 10:45:00', '2025-03-15 11:15:00'),
(10, 13, 9, 2, '2024-04-05 16:10:00', '2024-04-06 10:45:00'),
(15, 17, 10, 2, '2024-05-01 14:30:00', '2024-05-02 15:00:00'),
(18, 20, 11, 2, '2024-05-25 09:15:00', '2024-05-26 14:20:00'),
(21, 22, 12, 2, '2024-06-10 11:45:00', '2024-06-11 16:30:00'),

-- Empréstimos (tipo 3)
(3, 5, 13, 3, '2026-01-25 12:15:00', NULL),
(8, 11, 14, 3, '2026-02-28 10:30:00', NULL),
(11, 14, 1, 3, '2026-02-10 15:20:00', NULL),
(16, 19, 2, 3, '2024-04-10 14:10:00', NULL),
(20, 23, 3, 3, '2024-05-05 16:45:00', NULL),
(24, 26, 4, 3, '2024-06-01 09:30:00', NULL),

-- Vendas (tipo 4)
(5, 7, 5, 4, '2024-02-01 15:45:00', '2024-02-02 11:30:00'),
(9, 10, 6, 4, '2025-03-08 11:20:00', '2025-03-09 14:15:00'),
(13, 15, 7, 4, '2024-04-18 13:45:00', '2024-04-19 10:30:00'),
(14, 16, 8, 4, '2024-05-15 10:10:00', '2024-05-16 15:45:00'),
(17, 21, 9, 4, '2025-06-05 16:20:00', '2025-06-06 12:00:00'),
(22, 24, 10, 4, '2024-06-20 14:30:00', '2024-06-21 11:15:00'),
(25, 25, 11, 4, '2024-07-01 10:45:00', '2024-07-02 14:00:00');

-- ============================================
-- 8. INSERIR DETALHES DE ALUGUEL (7 registros)
-- ============================================
INSERT INTO Aluguel (transacao_id, prev_devolucao, update_date, data_devolucao, preco, multa) VALUES
(6, '2024-02-20', NULL, '2024-02-19', 30.00, NULL),
(7, '2024-03-15', '2024-03-10', '2024-03-12', 50.00, NULL),
(8, '2024-04-10', NULL, '2024-04-08', 25.00, NULL),
(9, '2024-05-05', NULL, NULL, 40.00, NULL),
(10, '2024-06-01', NULL, '2024-05-30', 35.00, NULL),
(11, '2024-06-25', NULL, NULL, 20.00, NULL),
(12, '2024-07-10', NULL, NULL, 45.00, NULL);

-- ============================================
-- 9. INSERIR DETALHES DE EMPRÉSTIMO (6 registros)
-- ============================================
INSERT INTO Emprestimo (transacao_id, prev_devolucao, update_date, data_devolucao) VALUES
(13, '2024-03-25', NULL, '2024-03-24'),
(14, '2024-04-28', NULL, '2024-04-25'),
(15, '2024-05-15', '2024-05-10', NULL),
(16, '2024-06-10', NULL, '2024-06-08'),
(17, '2024-07-05', NULL, NULL),
(18, '2024-08-01', NULL, NULL);

-- ============================================
-- 10. INSERIR DETALHES DE VENDA (7 registros)
-- ============================================
INSERT INTO Venda (transacao_id, preco) VALUES
(19, 1200.00),
(20, 350.00),
(21, 180.00),
(22, 220.00),
(23, 480.00),
(24, 75.00),
(25, 150.00);

-- ============================================
-- 11. INSERIR 20 AVALIAÇÕES (alguns itens com múltiplas avaliações)
-- ============================================
-- Item 1 (Furadeira) - 2 avaliações
INSERT INTO Avaliacao (transacao_id, avaliador_id, avaliado_id, nota, avaliacao) VALUES
(1, 2, 1, 9, 'Furadeira funcionou perfeitamente, João muito atencioso'),
(1, 1, 2, 8, 'Maria cuidou bem do equipamento, devolveu no prazo'),

-- Item 2 (Kindle) - 2 avaliações
(6, 4, 2, 10, 'Kindle em perfeito estado, muito satisfeito'),
(6, 2, 4, 9, 'Comprador pontual e cuidadoso'),

-- Item 3 (Livros) - 1 avaliação
(13, 5, 3, 7, 'Livros um pouco desgastados mas dentro do combinado'),

-- Item 4 (Bicicleta) - 2 avaliações
(7, 6, 4, 8, 'Bicicleta boa, só precisou calibrar os pneus'),
(7, 4, 6, 9, 'Pessoa cuidadosa, devolveu limpa'),

-- Item 5 (Furadeira Industrial) - 1 avaliação
(19, 7, 41, 10, 'Produto excelente, empresa muito profissional'),

-- Item 6 (Notebook) - 1 avaliação
(2, 3, 42, 9, 'Notebook funcionando perfeitamente'),

-- Item 7 (Guitarra) - 2 avaliações
(8, 9, 5, 8, 'Guitarra boa, amplificador pequeno mas funciona'),
(8, 5, 9, 7, 'Aluguel ok, mas atrasou 2 dias na devolução'),

-- Item 8 (Mesa) - 1 avaliação
(14, 11, 2, 6, 'Mesa com algumas marcas de uso, não mencionadas'),

-- Item 9 (Batedeira) - 1 avaliação
(20, 10, 6, 9, 'Batedeira excelente, muito boa para massas'),

-- Item 10 (Kit Ferramentas) - 1 avaliação
(9, 13, 7, 10, 'Kit completo, todas as peças em ótimo estado'),

-- Item 11 (Violão) - 1 avaliação
(15, 14, 8, 8, 'Violão bem cuidado, som excelente'),

-- Item 12 (Máquina de Lavar) - 1 avaliação
(3, 8, 9, 7, 'Funciona bem mas faz barulho no centrifugado'),

-- Item 13 (Skate) - 1 avaliação
(21, 15, 10, 10, 'Skate novinho, adorei!'),

-- Item 15 (Jogo de Xadrez) - 1 avaliação
(10, 17, 15, 9, 'Jogo lindo, peças bem feitas'),

-- Item 16 (Mochila) - 1 avaliação
(16, 19, 16, 8, 'Mochila espaçosa, ótima para camping'),

-- Item 22 (Ferro de Solda) - 1 avaliação
(24, 24, 22, 7, 'Funciona mas esquenta pouco, talvez precise trocar a ponta');

-- ============================================
-- 12. INSERIR PAGAMENTOS (25 registros - um para cada transação)
-- ============================================
INSERT INTO Pagamento (id_pagamento, transacao_id, metodo_pagamento, valor, status_pagamento, data_pagamento, id_gateway_externo) VALUES
(1, 1, 4, 0.00, 2, '2024-01-15 10:35:00', NULL),
(2, 2, 4, 0.00, 2, '2024-02-10 09:20:00', NULL),
(3, 3, 4, 0.00, 2, '2024-03-05 16:25:00', NULL),
(4, 4, 4, 0.00, 2, '2024-04-12 14:50:00', NULL),
(5, 5, 4, 0.00, 2, '2024-05-20 11:15:00', NULL),
(6, 6, 1, 30.00, 2, '2024-01-20 15:35:00', 'CC_123456'),
(7, 7, 4, 50.00, 2, '2024-02-15 13:25:00', 'PIX_789012'),
(8, 8, 1, 25.00, 2, '2024-03-10 10:50:00', 'CC_345678'),
(9, 9, 4, 40.00, 1, NULL, 'PIX_901234'),
(10, 10, 4, 35.00, 2, '2024-05-01 14:35:00', 'PIX_567890'),
(11, 11, 4, 20.00, 1, NULL, 'PIX_123789'),
(12, 12, 1, 45.00, 1, NULL, 'CC_456123'),
(13, 13, 4, 0.00, 2, '2024-01-25 12:20:00', NULL),
(14, 14, 4, 0.00, 2, '2024-02-28 10:35:00', NULL),
(15, 15, 4, 0.00, 1, NULL, NULL),
(16, 16, 4, 0.00, 2, '2024-04-10 14:15:00', NULL),
(17, 17, 4, 0.00, 1, NULL, NULL),
(18, 18, 4, 0.00, 1, NULL, NULL),
(19, 19, 1, 1200.00, 2, '2024-02-01 15:50:00', 'CC_789012'),
(20, 20, 4, 350.00, 2, '2024-03-08 11:25:00', 'PIX_345678'),
(21, 21, 4, 180.00, 2, '2024-04-18 13:50:00', 'PIX_901234'),
(22, 22, 1, 220.00, 2, '2024-05-15 10:15:00', 'CC_567890'),
(23, 23, 4, 480.00, 2, '2024-06-05 16:25:00', 'PIX_123789'),
(24, 24, 4, 75.00, 2, '2024-06-20 14:35:00', 'PIX_456123'),
(25, 25, 1, 150.00, 2, '2024-07-01 10:50:00', 'CC_789456');

-- ============================================
-- 13. INSERIR MANUTENÇÕES (12 registros - alguns itens com múltiplas manutenções)
-- ============================================
-- Item 1 (Furadeira) - 2 manutenções
INSERT INTO Manutencao (item_id, data_inicio_manutencao, data_fim_manutencao) VALUES
(1, '2023-12-01', '2023-12-05'),
(1, '2024-01-05', '2024-01-10'),

-- Item 4 (Bicicleta) - 2 manutenções
(4, '2024-02-25', '2024-02-28'),
(4, '2024-05-15', NULL),

-- Item 7 (Guitarra) - 1 manutenção
(7, '2024-03-01', '2024-03-05'),

-- Item 9 (Batedeira) - 1 manutenção
(9, '2024-02-10', '2024-02-15'),

-- Item 12 (Máquina de Lavar) - 2 manutenções
(12, '2024-01-20', '2024-01-25'),
(12, '2024-04-10', '2024-04-12'),

-- Item 15 (Jogo de Xadrez) - 1 manutenção
(15, '2024-03-15', '2024-03-18'),

-- Item 18 (Tablet) - 1 manutenção
(18, '2024-04-05', '2024-04-10'),

-- Item 21 (Caixa de Som) - 1 manutenção
(21, '2024-05-20', '2024-05-22'),

-- Item 22 (Ferro de Solda) - 1 manutenção
(22, '2024-06-01', NULL);

-- ============================================
-- 14. INSERIR MENSAGENS (20 registros)
-- ============================================
INSERT INTO Mensagem (hash_mensagem, item_id, remetente_id, destinatario_id, texto_mensagem, horario_mensagem) VALUES
(UUID(), 1, 2, 1, 'Olá, gostaria de alugar a furadeira por 30 dias', '2024-01-14 09:00:00'),
(UUID(), 1, 1, 2, 'Claro! Pode retirar amanhã no EcoPoint', '2024-01-14 09:05:00'),
(UUID(), 2, 4, 2, 'O Kindle ainda está disponível?', '2024-01-19 14:20:00'),
(UUID(), 2, 2, 4, 'Sim, está disponível para venda', '2024-01-19 14:22:00'),
(UUID(), 3, 5, 3, 'Posso pegar os livros emprestados por 1 mês?', '2024-01-24 16:45:00'),
(UUID(), 4, 6, 4, 'Interessado na bicicleta. Qual o valor do aluguel semanal?', '2024-02-14 11:30:00'),
(UUID(), 4, 4, 6, 'R$ 50 por semana, mínimo 2 semanas', '2024-02-14 11:32:00'),
(UUID(), 5, 7, 41, 'A furadeira de coluna tem garantia?', '2024-01-31 10:15:00'),
(UUID(), 5, 41, 7, 'Sim, 90 dias de garantia', '2024-01-31 10:18:00'),
(UUID(), 7, 9, 5, 'A guitarra vem com o amplificador?', '2024-03-09 15:40:00'),
(UUID(), 7, 5, 9, 'Sim, vem com amplificador pequeno de 10W', '2024-03-09 15:42:00'),
(UUID(), 9, 10, 6, 'A batedeira funciona bem para massa de pão?', '2024-03-07 09:25:00'),
(UUID(), 9, 6, 10, 'Sim, é planetária, perfeita para massas pesadas', '2024-03-07 09:27:00'),
(UUID(), 12, 8, 9, 'A máquina de lavar faz barulho?', '2024-03-04 13:10:00'),
(UUID(), 12, 9, 8, 'Faz um pouco no centrifugado, mas funciona bem', '2024-03-04 13:12:00'),
(UUID(), 15, 17, 15, 'O jogo de xadrez tem todas as peças?', '2024-04-30 16:55:00'),
(UUID(), 15, 15, 17, 'Sim, completo com 32 peças', '2024-04-30 16:57:00'),
(UUID(), 18, 20, 18, 'O tablet tem riscos na tela?', '2024-05-24 10:05:00'),
(UUID(), 18, 18, 20, 'Nenhum risco, está com película desde novo', '2024-05-24 10:07:00'),
(UUID(), 22, 24, 22, 'O ferro de solda esquenta rápido?', '2024-06-19 14:30:00');

-- ============================================
-- 15. INSERIR DENÚNCIAS (10 registros)
-- ============================================
INSERT INTO Denuncia (denuncia_denunciador_id, denuncia_alvo_id, denuncia_conteudo, denuncia_data, denuncia_estado, denuncia_responsavel) VALUES
(13, 22, 'Usuário não devolveu item combinado', '2024-02-28', 1, NULL),
(17, 35, 'Anúncio enganoso de produto', '2024-03-01', 2, 50),
(2, 67, 'Avaliação falsa e difamatória', '2024-03-02', 0, 50),
(6, 69, 'Item em estado muito pior do que anunciado', '2024-04-10', 1, NULL),
(8, 9, 'Usuário agressivo nas mensagens', '2024-04-15', 2, 49),
(10, 90, 'Transação não ocorreu na realidade', '2024-05-05', 0, 49),
(14, 11, 'Não compareceu no local combinado', '2024-05-20', 1, NULL),
(12, 61, 'Produto não funciona como descrito', '2024-06-10', 2, 48),
(13, 22, 'Múltiplas faltas em compromissos', '2024-06-25', 1, NULL),
(13, 22, 'Suspeita de conta falsa', '2024-07-01', 2, 48);