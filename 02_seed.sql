INSERT INTO Mensalidade_tipo (id_mensalidade, tipo_mensalidade) VALUES
(1, 'Sem mensalidade'),
(2, 'Basica'),
(3, 'Plus');

INSERT INTO Permissao (id_permissao, nome_permissao, pode_vender,
pode_comprar, pode_avaliar, pode_enviar_mensagens, pode_denunciar,
pode_ver_denuncias, pode_operar_em_itens, pode_operar_em_mensagens,
pode_operar_em_avaliacoes, pode_operar_em_usuarios,
pode_operar_em_denuncias, pode_operar_no_sistema) VALUES
(1, 'Conta suspensa', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(2, 'Conta ativa', 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0),
(3,'Conta de moderação', 0 ,0 ,0 ,1 ,1 ,1 ,0 ,1 ,1 ,0 ,0 ,0),
(4,'Conta de administração', 1 ,1 ,1 ,1 ,1 ,1 ,1 ,1 ,1 ,1 ,1 ,1);

INSERT INTO Estado_tipo (id_estado, tipo_estado) VALUES
(1, 'Novo'),
(2, 'Seminovo'),
(3, 'Usado');

INSERT INTO Disponibilidade_tipo (id_disponibilidade, tipo_disponibilidade) VALUES
(1, 'Disponível'),
(2, 'Indisponível'),
(3, 'Em uso'),
(4, 'Em manutenção');


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

GRANT SELECT ON ECOSHARE.Transacao TO moderador;
GRANT SELECT ON ECOSHARE.Aluguel TO moderador;
GRANT SELECT ON ECOSHARE.Emprestimo TO moderador;
GRANT SELECT ON ECOSHARE.Doacao TO moderador;

-- Usuário
GRANT SELECT ON ECOSHARE.* TO user_app;

GRANT INSERT ON ECOSHARE.Transacao TO user_app;
GRANT INSERT ON ECOSHARE.Aluguel TO user_app;
GRANT INSERT ON ECOSHARE.Emprestimo TO user_app;
GRANT INSERT ON ECOSHARE.Doacao TO user_app;

GRANT INSERT ON ECOSHARE.Mensagem TO user_app;
GRANT INSERT ON ECOSHARE.Avaliacao TO user_app;
GRANT INSERT ON ECOSHARE.Denuncia TO user_app;

GRANT UPDATE ON ECOSHARE.Item TO user_app;

-- Criação de usuários e atribuição de papéis
CREATE USER 'app_admin' IDENTIFIED BY 'senha1';
CREATE USER 'app_mod' IDENTIFIED BY 'senha2';
CREATE USER 'app_user' IDENTIFIED BY 'senha3';

GRANT admin TO 'app_admin';
GRANT moderador TO 'app_mod';
GRANT user_app TO 'app_user';

SET DEFAULT ROLE admin TO 'app_admin';
SET DEFAULT ROLE moderador TO 'app_mod';
SET DEFAULT ROLE user_app TO 'app_user';