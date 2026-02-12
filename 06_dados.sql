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
(2, 4, 6, 2, '2024-01-20 15:30:00', '2024-01-21 12:00:00'),
(4, 6, 7, 2, '2024-02-15 13:20:00', '2024-02-16 14:30:00'),
(7, 9, 8, 2, '2024-03-10 10:45:00', '2024-03-11 11:15:00'),
(10, 13, 9, 2, '2024-04-05 16:10:00', '2024-04-06 10:45:00'),
(15, 17, 10, 2, '2024-05-01 14:30:00', '2024-05-02 15:00:00'),
(18, 20, 11, 2, '2024-05-25 09:15:00', '2024-05-26 14:20:00'),
(21, 22, 12, 2, '2024-06-10 11:45:00', '2024-06-11 16:30:00'),

-- Empréstimos (tipo 3)
(3, 5, 13, 3, '2024-01-25 12:15:00', NULL),
(8, 11, 14, 3, '2024-02-28 10:30:00', NULL),
(11, 14, 1, 3, '2024-03-15 15:20:00', NULL),
(16, 19, 2, 3, '2024-04-10 14:10:00', NULL),
(20, 23, 3, 3, '2024-05-05 16:45:00', NULL),
(24, 26, 4, 3, '2024-06-01 09:30:00', NULL),

-- Vendas (tipo 4)
(5, 7, 5, 4, '2024-02-01 15:45:00', '2024-02-02 11:30:00'),
(9, 10, 6, 4, '2024-03-08 11:20:00', '2024-03-09 14:15:00'),
(13, 15, 7, 4, '2024-04-18 13:45:00', '2024-04-19 10:30:00'),
(14, 16, 8, 4, '2024-05-15 10:10:00', '2024-05-16 15:45:00'),
(17, 21, 9, 4, '2024-06-05 16:20:00', '2024-06-06 12:00:00'),
(22, 24, 10, 4, '2024-06-20 14:30:00', '2024-06-21 11:15:00'),
(25, 25, 11, 4, '2024-07-01 10:45:00', '2024-07-02 14:30:00');

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