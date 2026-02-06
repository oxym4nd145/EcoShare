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