USE ECOSHARE;

-- 1. Populando alguns endereços para os usuários
INSERT INTO Endereco (cep, logradouro, numero, bairro, cidade, estado) VALUES
('01001-000', 'Praça da Sé', '10', 'Sé', 'São Paulo', 'SP'),
('20040-002', 'Avenida Rio Branco', '100', 'Centro', 'Rio de Janeiro', 'RJ'),
('30140-010', 'Rua da Bahia', '500', 'Lourdes', 'Belo Horizonte', 'MG'),
('70040-010', 'Eixo Monumental', 'S/N', 'Asa Sul', 'Brasília', 'DF'),
('80010-000', 'Rua XV de Novembro', '250', 'Centro', 'Curitiba', 'PR');

-- 2. Populando 50 usuários
-- Alternando entre PF (tipo 1) e PJ (tipo 2), e diferentes mensalidades
INSERT INTO Usuario (mensalidade_id, nivel_permissao, nome_usuario, email, tipo_pessoa, hash_senha, data_nascimento, saldo, endereco) VALUES
(1, 2, 'Ana Silva', 'ana.silva@email.com', 1, 'hash_std_1', '1990-05-15', 50.00, 1),
(2, 2, 'Bruno Santos', 'bruno.santos@email.com', 1, 'hash_std_2', '1985-10-20', 10.00, 2),
(3, 2, 'Carlos Oliveira', 'carlos.oliveira@email.com', 1, 'hash_std_3', '1992-03-12', 150.00, 3),
(1, 2, 'Daniela Lima', 'daniela.lima@email.com', 1, 'hash_std_4', '1988-07-30', 0.00, 4),
(2, 2, 'Eduardo Costa', 'eduardo.costa@email.com', 1, 'hash_std_5', '1995-12-05', 25.50, 5),
(1, 2, 'Fernanda Souza', 'fernanda.souza@email.com', 1, 'hash_std_6', '1993-01-22', 75.00, 1),
(2, 2, 'Gabriel Almeida', 'gabriel.almeida@email.com', 1, 'hash_std_7', '1980-11-11', 12.00, 2),
(3, 2, 'Helena Rodrigues', 'helena.rodrigues@email.com', 1, 'hash_std_8', '1991-09-09', 300.00, 3),
(1, 2, 'Igor Pereira', 'igor.pereira@email.com', 1, 'hash_std_9', '1987-04-18', 0.00, 4),
(2, 2, 'Juliana Martins', 'juliana.martins@email.com', 1, 'hash_std_10', '1994-06-25', 45.00, 5),
(1, 2, 'Kevin Rocha', 'kevin.rocha@email.com', 1, 'hash_std_11', '1996-08-14', 10.00, 1),
(2, 2, 'Larissa Mendes', 'larissa.mendes@email.com', 1, 'hash_std_12', '1989-02-28', 88.00, 2),
(3, 2, 'Marcos Vinicius', 'marcos.vinicius@email.com', 1, 'hash_std_13', '1982-05-05', 500.00, 3),
(1, 2, 'Natalia Ramos', 'natalia.ramos@email.com', 1, 'hash_std_14', '1997-10-10', 0.00, 4),
(2, 2, 'Otavio Castro', 'otavio.castro@email.com', 1, 'hash_std_15', '1984-12-12', 33.40, 5),
(1, 2, 'Patricia Gomes', 'patricia.gomes@email.com', 1, 'hash_std_16', '1990-03-21', 15.00, 1),
(2, 2, 'Ricardo Faria', 'ricardo.faria@email.com', 1, 'hash_std_17', '1986-07-07', 20.00, 2),
(3, 2, 'Sabrina Paiva', 'sabrina.paiva@email.com', 1, 'hash_std_18', '1993-09-15', 120.00, 3),
(1, 2, 'Thiago Neves', 'thiago.neves@email.com', 1, 'hash_std_19', '1981-01-01', 5.00, 4),
(2, 2, 'Ursula Lima', 'ursula.lima@email.com', 1, 'hash_std_20', '1995-04-04', 60.00, 5),
(1, 2, 'Vitor Hugo', 'vitor.hugo@email.com', 1, 'hash_std_21', '1992-06-06', 0.00, 1),
(2, 2, 'Wanessa Camargo', 'wanessa.c@email.com', 1, 'hash_std_22', '1988-08-08', 40.00, 2),
(3, 2, 'Xavier Neto', 'xavier.neto@email.com', 1, 'hash_std_23', '1983-10-10', 250.00, 3),
(1, 2, 'Yara Silva', 'yara.silva@email.com', 1, 'hash_std_24', '1996-12-20', 10.50, 4),
(2, 2, 'Zeca Pagodinho', 'zeca.p@email.com', 1, 'hash_std_25', '1975-02-02', 1000.00, 5),
(1, 2, 'Tech Soluções', 'contato@techsolucoes.com', 2, 'hash_pj_26', '2010-01-01', 5000.00, 1),
(2, 2, 'Eco Rent', 'financeiro@ecorent.com', 2, 'hash_pj_27', '2015-05-10', 2500.00, 2),
(3, 2, 'Ferramentas SA', 'vendas@ferramentas.com', 2, 'hash_pj_28', '2005-08-20', 8000.00, 3),
(1, 2, 'Bicicletaria Silva', 'bike@silva.com', 2, 'hash_pj_29', '2018-03-15', 400.00, 4),
(2, 2, 'Eventos Express', 'eventos@express.com', 2, 'hash_pj_30', '2020-09-01', 1200.00, 5),
(1, 2, 'Alice Cooper', 'alice.c@email.com', 1, 'hash_std_31', '1980-04-14', 15.00, 1),
(2, 2, 'Bob Burnquist', 'bob.b@email.com', 1, 'hash_std_32', '1976-10-10', 450.00, 2),
(1, 2, 'Catarina Grande', 'cat.grande@email.com', 1, 'hash_std_33', '1998-11-23', 20.00, 3),
(3, 2, 'Diego Maradona', 'diego.m@email.com', 1, 'hash_std_34', '1960-10-30', 0.00, 4),
(1, 2, 'Elaine Pereira', 'elaine.p@email.com', 1, 'hash_std_35', '1984-05-19', 12.00, 5),
(2, 2, 'Fabio Assuncao', 'fabio.a@email.com', 1, 'hash_std_36', '1971-08-10', 55.00, 1),
(1, 2, 'Gisele Bündchen', 'gisele.b@email.com', 1, 'hash_std_37', '1980-07-20', 900.00, 2),
(3, 2, 'Helio de la Peña', 'helio.p@email.com', 1, 'hash_std_38', '1959-07-09', 15.00, 3),
(1, 2, 'Iris Rezende', 'iris.r@email.com', 1, 'hash_std_39', '1933-12-22', 0.00, 4),
(2, 2, 'Jorge Ben', 'jorge.ben@email.com', 1, 'hash_std_40', '1942-03-22', 200.00, 5),
(1, 2, 'Klara Castanho', 'klara.c@email.com', 1, 'hash_std_41', '2000-10-06', 30.00, 1),
(2, 2, 'Luan Santana', 'luan.s@email.com', 1, 'hash_std_42', '1991-03-13', 1500.00, 2),
(3, 2, 'Marina Ruy', 'marina.ruy@email.com', 1, 'hash_std_43', '1995-06-30', 800.00, 3),
(1, 2, 'Neymar Junior', 'ney.jr@email.com', 1, 'hash_std_44', '1992-02-05', 10000.00, 4),
(2, 2, 'Oscar Niemeyer', 'oscar.n@email.com', 1, 'hash_std_45', '1907-12-15', 5.00, 5),
(1, 2, 'Paulo Coelho', 'paulo.c@email.com', 1, 'hash_std_46', '1947-08-24', 300.00, 1),
(3, 2, 'Quitéria Chagas', 'quiteria.c@email.com', 1, 'hash_std_47', '1980-09-10', 40.00, 2),
(1, 2, 'Ronaldinho Gaucho', 'bruxo@email.com', 1, 'hash_std_48', '1980-03-21', 0.00, 3),
(2, 2, 'Sonia Braga', 'sonia.b@email.com', 1, 'hash_std_49', '1950-06-08', 90.00, 4),
(1, 2, 'Tarcísio Meira', 'tarcisio.m@email.com', 1, 'hash_std_50', '1935-10-05', 10.00, 5);

-- 3. Populando CPFs para os usuários que são PF (ID 1 a 25 e 31 a 50)
-- Nota: CPFs fictícios para exemplo
INSERT INTO Cpf (usuario_id, cpf)
SELECT id_usuario, LPAD(id_usuario, 11, '0') 
FROM Usuario 
WHERE tipo_pessoa = 1;

-- 4. Populando CNPJs para os usuários que são PJ (ID 26 a 30)
INSERT INTO Cnpj (usuario_id, cnpj)
SELECT id_usuario, LPAD(id_usuario, 14, '0') 
FROM Usuario 
WHERE tipo_pessoa = 2;

INSERT INTO Categoria_tipo (tipo_categoria) VALUES 
('Ferramentas'), ('Eletrônicos'), ('Jardinagem'), ('Esporte e Lazer'), ('Utensílios Domésticos');

INSERT INTO Item (dono_id, nome_item, categoria, status_item, estado_conservacao, descricao) VALUES
(1, 'Furadeira Bosch', 1, 1, 1, 'Furadeira de impacto semi-nova, com maleta.'),
(2, 'Monitor 24 Pol', 2, 1, 2, 'Monitor LED Dell, resolução Full HD.'),
(3, 'Cortador de Grama', 3, 1, 3, 'Cortador elétrico, ideal para jardins pequenos.'),
(4, 'Bola de Basquete', 4, 1, 1, 'Bola Spalding oficial, nunca usada.'),
(5, 'Air Fryer Mondial', 5, 1, 2, 'Fritadeira sem óleo, funcionando perfeitamente.'),
(6, 'Escada de Alumínio', 1, 1, 1, 'Escada articulada de 12 degraus.'),
(7, 'Notebook HP', 2, 1, 3, 'Notebook antigo, mas bom para tarefas básicas.'),
(8, 'Vaso de Cerâmica', 3, 1, 1, 'Vaso grande para decoração externa.'),
(9, 'Barraca 4 Pessoas', 4, 1, 2, 'Barraca de camping impermeável.'),
(10, 'Batedeira Planetária', 5, 1, 2, 'Batedeira branca, 110v.'),
(11, 'Serra Circular', 1, 1, 1, 'Serra profissional com disco extra.'),
(12, 'Tablet Samsung', 2, 1, 2, 'Tablet com caneta para desenho.'),
(13, 'Kit de Pás', 3, 1, 3, 'Conjunto de ferramentas para horta.'),
(14, 'Prancha de Surf', 4, 1, 2, 'Prancha 6.0, com alguns reparos.'),
(15, 'Jogo de Panelas', 5, 1, 1, 'Kit com 5 panelas antiaderentes.'),
(16, 'Parafusadeira', 1, 1, 1, 'A bateria, acompanha carregador.'),
(17, 'Câmera Canon T7', 2, 1, 2, 'Câmera DSLR com lente 18-55mm.'),
(18, 'Mangueira 20m', 3, 1, 2, 'Mangueira de jardim com esguicho.'),
(19, 'Bicicleta Aro 29', 4, 1, 3, 'Bike de trilha, revisada recentemente.'),
(20, 'Liquidificador', 5, 1, 1, 'Potente, com copo de vidro.'),
(21, 'Martelete', 1, 1, 2, 'Ideal para quebrar concreto leve.'),
(22, 'Teclado Mecânico', 2, 1, 1, 'Switch azul, iluminação RGB.'),
(23, 'Podador de Cerca', 3, 1, 2, 'Podador elétrico manual.'),
(24, 'Patins In-line', 4, 1, 2, 'Tamanho 38-40, com kit proteção.'),
(25, 'Micro-ondas', 5, 1, 3, 'Modelo antigo, mas esquenta bem.'),
(26, 'Gerador de Energia', 1, 1, 1, 'Gerador a gasolina para eventos (Empresa Tech).'),
(27, 'Projetor Epson', 2, 1, 2, 'Projetor para palestras e filmes (Eco Rent).'),
(28, 'Betoneira 400L', 1, 1, 2, 'Equipamento pesado para obra (Ferramentas SA).'),
(29, 'Suporte de Bicicleta', 4, 1, 1, 'Suporte para carro (Bicicletaria Silva).'),
(30, 'Caixa de Som Ativa', 2, 1, 2, 'Som profissional para festas (Eventos Express).'),
(31, 'Nível Laser', 1, 1, 1, 'Nível automático de alta precisão.'),
(32, 'Skate Profissional', 4, 1, 2, 'Shape de marfim, rodas novas.'),
(33, 'Roteador Wi-Fi 6', 2, 1, 1, 'Alta velocidade, longo alcance.'),
(34, 'Chuteira Society', 4, 1, 2, 'Tamanho 42, pouco uso.'),
(35, 'Ferro de Passar', 5, 1, 3, 'Ferro a vapor cerâmico.'),
(36, 'Lixadeira Orbital', 1, 1, 2, 'Para acabamento em madeira.'),
(37, 'Ring Light', 2, 1, 1, 'Tripé de 2 metros para vídeos.'),
(38, 'Ancinho de Metal', 3, 1, 2, 'Para limpeza de folhas e grama.'),
(39, 'Mala de Viagem G', 4, 1, 2, 'Rígida, com 4 rodinhas 360.'),
(40, 'Violão Acústico', 4, 1, 3, 'Corda de nylon, bom para iniciantes.'),
(41, 'Fone Bluetooth', 2, 1, 1, 'Cancelamento de ruído ativo.'),
(42, 'Violão Elétrico', 4, 1, 2, 'Modelo Folk com afinador.'),
(43, 'Secador de Cabelo', 5, 1, 1, 'Profissional, 2000W.'),
(44, 'Mesa de Som 4 Ch', 2, 1, 2, 'Interface USB integrada.'),
(45, 'Compasso de Madeira', 1, 1, 3, 'Antiguidade de marcenaria.'),
(46, 'Livro de Receitas', 5, 1, 1, 'Edição de colecionador.'),
(47, 'Fantasia Carnaval', 4, 1, 2, 'Traje completo de pirata.'),
(48, 'Cooler 30 Litros', 4, 1, 2, 'Caixa térmica com alça.'),
(49, 'Aspirador de Pó', 5, 1, 2, 'Modelo vertical 2 em 1.'),
(50, 'Scanner de Fotos', 2, 1, 3, 'Digitaliza negativos e fotos antigas.');

INSERT INTO Mensagem (hash_mensagem, item_id, remetente_id, destinatario_id, texto_mensagem) VALUES
(UUID(), 1, 2, 1, 'Olá Ana, a furadeira está com as brocas inclusas?'),
(UUID(), 1, 1, 2, 'Oi Bruno! Sim, acompanha um jogo de 5 brocas para concreto.'),
(UUID(), 19, 10, 19, 'Thiago, tenho interesse em alugar sua bike no final de semana.'),
(UUID(), 19, 19, 10, 'Perfeito Juliana, ela está revisada e pronta para trilha.'),
(UUID(), 27, 42, 27, 'Eco Rent, o projetor tem entrada HDMI?'),
(UUID(), 27, 27, 42, 'Olá Luan, possui HDMI, VGA e suporte a Wi-Fi.');

-- Venda (Tipo 4)
INSERT INTO Transacao (item_id, comprador_id, tipo_transacao) VALUES (1, 2, 4);
INSERT INTO Venda (transacao_id, preco) VALUES (LAST_INSERT_ID(), 250.00);

-- Aluguel (Tipo 2)
INSERT INTO Transacao (item_id, comprador_id, tipo_transacao) VALUES (19, 10, 2);
INSERT INTO Aluguel (transacao_id, prev_devolucao, preco) 
VALUES (LAST_INSERT_ID(), DATE_ADD(CURDATE(), INTERVAL 2 DAY), 80.00);

-- Empréstimo (Tipo 3)
INSERT INTO Transacao (item_id, comprador_id, tipo_transacao) VALUES (6, 15, 3);
INSERT INTO Emprestimo (transacao_id, prev_devolucao) 
VALUES (LAST_INSERT_ID(), DATE_ADD(CURDATE(), INTERVAL 5 DAY));

-- Doação (Tipo 1) - Ativa trg_pos_transacao diretamente
INSERT INTO Transacao (item_id, comprador_id, tipo_transacao) VALUES (35, 39, 1);

INSERT INTO Avaliacao (transacao_id, avaliador_id, avaliado_id, nota, avaliacao) VALUES
(1, 2, 1, 10, 'Ana foi super atenciosa e o produto está impecável.'),
(2, 10, 19, 9, 'Bike excelente, a entrega no ponto de coleta foi pontual.'),
(3, 15, 6, 8, 'A escada me ajudou muito na pintura, recomendo o dono.'),
(4, 39, 35, 10, 'Muito obrigado pela doação do ferro, vai ser muito útil!');