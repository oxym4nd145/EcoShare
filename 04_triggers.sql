DELIMITER //

-- ALteração da disponibilidade em caso de manutenção
-- 1. Ao iniciar manutenção -> Muda para 4 (Em manutenção)
CREATE TRIGGER trg_inicio_manutencao
AFTER INSERT ON Manutencao
FOR EACH ROW
BEGIN
    UPDATE Item
    SET disponibilidade = 4 -- ID fixo conforme sua regra
    WHERE id_item = NEW.item_id;
END;
//

-- 2. Ao finalizar manutenção (data_fim preenchida) -> Muda para 1 (Disponível)
CREATE TRIGGER trg_fim_manutencao
AFTER UPDATE ON Manutencao
FOR EACH ROW
BEGIN
    -- Se a data fim foi preenchida agora
    IF OLD.data_fim_manutencao IS NULL AND NEW.data_fim_manutencao IS NOT NULL THEN
        UPDATE Item
        SET disponibilidade = 1 -- Volta a ficar Disponível
        WHERE id_item = NEW.item_id;
    END IF;
END;
//

-- 3. Mudança de estado ao confirmar um Aluguel
CREATE TRIGGER trg_novo_aluguel
AFTER INSERT ON Aluguel
FOR EACH ROW
BEGIN
    -- Busca o item_id através da tabela pai Transacao
    UPDATE Item
    SET disponibilidade = 3 -- Em uso
    WHERE id_item = (SELECT item_id FROM Transacao WHERE id_transacao = NEW.transacao_id);
END;
//

-- 4. Mudança de estado ao confirmar um Empréstimo
CREATE TRIGGER trg_novo_emprestimo
AFTER INSERT ON Emprestimo
FOR EACH ROW
BEGIN
    UPDATE Item
    SET disponibilidade = 3 -- Em uso
    WHERE id_item = (SELECT item_id FROM Transacao WHERE id_transacao = NEW.transacao_id);
END;
//

-- 5. Mudança de estado em caso de doação
CREATE TRIGGER trg_nova_doacao
AFTER INSERT ON Doacao
FOR EACH ROW
BEGIN
    UPDATE Item
    SET disponibilidade = 2 -- Indisponível (Já foi doado)
    WHERE id_item = (SELECT item_id FROM Transacao WHERE id_transacao = NEW.transacao_id);
END;
//

-- 6. Verifica disponibilidade
CREATE TRIGGER trg_valida_disponibilidade_item
BEFORE INSERT ON Transacao
FOR EACH ROW
BEGIN
    DECLARE estado_atual INT;
    
    SELECT disponibilidade INTO estado_atual 
    FROM Item 
    WHERE id_item = NEW.item_id;
    
    -- Se NÃO for 1 (Disponível), cancela a operação
    IF estado_atual != 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Operação negada: Este item não está disponível para transação.';
    END IF;
END;
//

-- 7. Alteração do status após devolução
CREATE TRIGGER trg_devolucao_item
AFTER UPDATE ON Transacao
FOR EACH ROW
BEGIN
    -- Se a data de devolução real foi preenchida (item retornou)
    -- E o item não foi uma doação (verificamos se não virou estado 2)
    IF OLD.data_devolucao_real IS NULL AND NEW.data_devolucao_real IS NOT NULL THEN
        
        UPDATE Item
        SET disponibilidade = 1 -- Volta a ser Disponível
        WHERE id_item = NEW.item_id 
        AND disponibilidade = 3; -- Só altera se estiver "Em uso"
        
    END IF;
END;
//

-- 8. Impede autonegociação
CREATE TRIGGER trg_impede_autonegociacao
BEFORE INSERT ON Transacao
FOR EACH ROW
BEGIN
    IF NEW.vendedor_id = NEW.comprador_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro: O proprietário não pode realizar transações com seu próprio item.';
    END IF;
END;
//

DELIMITER ;