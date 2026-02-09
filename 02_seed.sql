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

INSERT INTO Objeto_tipo (id_objeto_tipo, objeto_tipo) VALUES
(1, 'Usuário'),
(2, 'Item'),
(3, 'Avaliação'),
(4, 'Mensagem'),
(5, 'Transação');

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