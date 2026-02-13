function formatarClasse(texto) {
    if (!texto) return 'default';
    return texto
        .toLowerCase()
        .normalize('NFD')
        .replace(/[\u0300-\u036f]/g, "") 
        .replace(/\s+/g, '-')
        .trim();
}

// Formata CPF (11 dígitos) para 000.000.000-00
function formatarDocumento(doc) {
    if (!doc) return '';
    const numeros = doc.replace(/\D/g, '');
    
    if (numeros.length === 11) {
        // CPF
        return numeros.slice(0, 3) + '.' + numeros.slice(3, 6) + '.' + numeros.slice(6, 9) + '-' + numeros.slice(9);
    } else if (numeros.length === 14) {
        // CNPJ
        return numeros.slice(0, 2) + '.' + numeros.slice(2, 5) + '.' + numeros.slice(5, 8) + '/' + numeros.slice(8, 12) + '-' + numeros.slice(12);
    }
    return doc;
}

// Formata CEP para 00000-000
function formatarCEP(cep) {
    if (!cep) return '';
    const numeros = cep.replace(/\D/g, '');
    return numeros.slice(0, 5) + '-' + numeros.slice(5);
}

async function carregarPerfil() {
    // --- PEGAR ID DO LOGIN ---
    const USUARIO_ID = localStorage.getItem('usuario_id');

    // Proteção: Se não estiver logado, redireciona
    if (!USUARIO_ID) {
        window.location.href = 'login.html';
        return;
    }

    try {
        console.log('Iniciando carregarPerfil para usuário:', USUARIO_ID);
        
        const url = `http://localhost:3000/api/usuario/completo/${USUARIO_ID}`;
        console.log('Requisição para:', url);
        
        const resposta = await fetch(url);
        
        console.log('Status da resposta:', resposta.status, resposta.ok);
        
        if (!resposta.ok) {
            const errorText = await resposta.text();
            console.error('Erro HTTP - Status:', resposta.status);
            console.error('Erro texto:', errorText);
            alert('Erro ' + resposta.status + ': ' + errorText);
            return;
        }
        
        const user = await resposta.json();

        console.log('Resposta completa da API:', user);

        // Foto de perfil
        const imgElement = document.getElementById('user-foto');
        if (imgElement) {
            imgElement.src = 'src/imgs/user-gray.svg';
        }

        // 1. Preenchimento de Informações Básicas
        setElementText('user-nome', user.nome_usuario || '...');
        setElementText('user-email', user.email || '...');
        
        // 2. Badge de Mensalidade
        const badgeMensalidade = document.getElementById('user-mensalidade-badge');
        if (badgeMensalidade) {
            badgeMensalidade.innerText = 'Grátis';
        }

        // 3. Dados Financeiros
        const saldoFormatado = (user.saldo || 0).toLocaleString('pt-BR', { 
            style: 'currency', 
            currency: 'BRL' 
        });
        setElementText('user-saldo', saldoFormatado);

        // 4. Datas e Pessoais
        if (user.data_nascimento) {
            const data = new Date(user.data_nascimento);
            setElementText('user-data-nasc', data.toLocaleDateString('pt-BR'));
        }

        // Tipo de Pessoa
        setElementText('user-tipo-pessoa', 'Pessoa Física');
        
        // Documento
        if (user.documento) {
            const tipoDoc = user.documento.length === 11 ? 'CPF' : 'Documento';
            setElementText('user-tipo-documento', `${tipoDoc}:`);
            const docFormatado = formatarDocumento(user.documento);
            setElementText('user-documento', docFormatado);
        } else {
            setElementText('user-tipo-documento', 'Documento:');
            setElementText('user-documento', 'Não informado');
        }

        // Endereço - dados do banco
        setElementText('user-cep', user.cep ? formatarCEP(user.cep) : 'Não informado');
        setElementText('user-logradouro', user.logradouro || '...');
        setElementText('user-numero', user.numero || 'S/N');
        setElementText('user-bairro', user.bairro || '...');
        setElementText('user-cidade', user.cidade || '...');
        setElementText('user-uf', user.estado || '..');

        // Renderizar transações
        renderizarTransacoes(user.transacoes || []);

    } catch (error) {
        console.error("Erro ao carregar perfil:", error);
        alert('Erro: ' + error.message);
    }
}

async function deletarItem(itemId, itemNome) {
    if (!confirm(`Tem certeza que deseja deletar "${itemNome}"?\nEsta ação não pode ser desfeita.`)) {
        return;
    }

    const usuarioId = localStorage.getItem('usuario_id');
    if (!usuarioId) {
        alert('Você precisa estar logado.');
        return;
    }

    try {
        const resposta = await fetch(`http://localhost:3000/api/itens/${itemId}`, {
            method: 'DELETE',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ usuario_id: usuarioId })
        });

        if (!resposta.ok) {
            const erro = await resposta.json();
            throw new Error(erro.error || 'Erro ao deletar');
        }

        alert('Item deletado com sucesso!');
        // Recarregar a lista de itens
        await carregarMeusItens();
        carregarHistoricoTransacoes();
    } catch (erro) {
        console.error('Erro:', erro);
        alert('Erro: ' + erro.message);
    }
}

async function carregarMeusItens() {
    const container = document.getElementById('meus-itens-container');
    const usuarioId = localStorage.getItem('usuario_id');

    if (!usuarioId) {
        container.innerHTML = '<p>Faça login para ver seus itens.</p>';
        return;
    }

    try {
        const resposta = await fetch(`http://localhost:3000/api/usuario/${usuarioId}/itens`);
        const itens = await resposta.json();

        if (itens.length === 0) {
            container.innerHTML = '<p>Você ainda não cadastrou nenhum item.</p>';
            return;
        }

        // Criar os cards dos itens
        container.innerHTML = itens.map(item => `
            <div class="product-card-wrapper" data-item-id="${item._id}">
                <a href="item.html?id=${item._id}" class="product-card">
                    <div class="img-container">
                        <img src="${item.foto || './src/imgs/recycle-sign.svg'}" alt="${item.nome}">
                    </div>
                    <div class="card-info">
                        <div style="display: flex; justify-content: space-between;">
                            <span class="badge type-${formatarClasse(item.tipo)}">
                                ${item.tipo}
                            </span>
                            <div class="item-alter-btns" style="display: flex; gap: .5rem;">
                                <button class="btn-editar" style="background: none; border: none; cursor: pointer;">
                                    <img src="./src/imgs/edit.svg" alt="Editar" class="icon" style="height: auto; width: 1.4rem">
                                </button>
                                <button class="btn-deletar" style="background: none; border: none; cursor: pointer;">
                                    <img src="./src/imgs/trash.svg" alt="Deletar" class="icon" style="height: auto; width: 1.4rem">
                                </button>
                            </div>
                        </div>
                        <h3>${item.nome}</h3>
                    </div>
                </a>
            </div>
        `).join('');

        // Adicionar event listeners para cada botão de editar e deletar
        itens.forEach(item => {
            // Encontrar o wrapper específico deste item
            const itemWrapper = container.querySelector(`[data-item-id="${item._id}"]`);
            
            if (itemWrapper) {
                // Botão de editar
                const btnEditar = itemWrapper.querySelector('.btn-editar');
                if (btnEditar) {
                    btnEditar.addEventListener('click', (e) => {
                        e.preventDefault(); // Prevenir navegação do link
                        e.stopPropagation(); // Prevenir propagação do evento
                        window.location.href = `edit-item.html?id=${item._id}`;
                    });
                }

                // Botão de deletar
                const btnDeletar = itemWrapper.querySelector('.btn-deletar');
                if (btnDeletar) {
                    btnDeletar.addEventListener('click', async (e) => {
                        e.preventDefault(); // Prevenir navegação do link
                        e.stopPropagation(); // Prevenir propagação do evento
                        
                        if (confirm(`Tem certeza que deseja deletar "${item.nome}"?`)) {
                            await deletarItem(item._id, item.nome);
                        }
                    });
                }
            }
        });

    } catch (erro) {
        console.error("Erro:", erro);
        container.innerHTML = '<p>Erro ao carregar inventário.</p>';
    }
}

/**
 * Função para renderizar a lista de transações ou mensagem de vazio
 */
// --- 3. CARREGAMENTO DO HISTÓRICO DE TRANSAÇÕES ---

async function carregarHistoricoTransacoes() {
    const USUARIO_ID = localStorage.getItem('usuario_id');

    // Proteção: Se não estiver logado, redireciona
    if (!USUARIO_ID) {
        window.location.href = 'login.html';
        return;
    }

    const container = document.getElementById('transaction-history');
    if (!container) return;

    try {
        const resposta = await fetch(`http://localhost:3000/api/usuario/${USUARIO_ID}/transacoes`);
        const transacoes = await resposta.json();
        console.log('resposta obtida');

        renderizarTransacoes(transacoes);

    } catch (error) {
        console.error("Erro nas transações:", error);
        renderizarTransacoes([]); // Renderiza estado vazio em caso de erro
    }
}

/**
 * Transforma os dados do Banco em linhas de tabela HTML
 */
function renderizarTransacoes(transacoes) {
    const container = document.getElementById('transaction-history');
    container.innerHTML = ''; // Limpa o "Carregando..."

    if (!transacoes || transacoes.length === 0) {
        container.innerHTML = `
            <tr>
                <td colspan="4" class="mensagem-vazia" style="text-align: center; padding: 20px;">
                    <div style="display: flex; flex-direction: column; align-items: center; gap: 10px;">
                        <img src="./src/imgs/filter.svg" alt="Ícone" style="width: 30px; opacity: 0.5;">
                        <p style="margin: 0;">Nenhuma transação encontrada.</p>
                        <small style="color: #666;">Suas atividades aparecerão aqui.</small>
                    </div>
                </td>
            </tr>
        `;
        return;
    }

    transacoes.forEach(t => {
        const row = document.createElement('tr');
        
        const data = t.data_transacao ? new Date(t.data_transacao).toLocaleDateString('pt-BR') : '-';
        

        row.innerHTML = `
            <td><strong>${t.nome_item}</strong></td>
            <td>${t.tipo_transacao}</td>
            <td>${data}</td>
        `;
        container.appendChild(row);
    });
}

/**
 * Helper para evitar erros caso o ID não exista no HTML
 */
function setElementText(id, text) {
    const el = document.getElementById(id);
    if (el) el.innerText = text;
}

async function deletarItem(itemId, itemNome) {
    if (!confirm(`Tem certeza que deseja deletar "${itemNome}"?\nEsta ação não pode ser desfeita.`)) {
        return;
    }

    const usuarioId = localStorage.getItem('usuario_id');
    if (!usuarioId) {
        alert('Você precisa estar logado.');
        return;
    }

    try {
        const resposta = await fetch(`http://localhost:3000/api/itens/${itemId}`, {
            method: 'DELETE',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ usuario_id: usuarioId })
        });

        if (!resposta.ok) {
            const erro = await resposta.json();
            throw new Error(erro.error || 'Erro ao deletar');
        }

        alert('Item deletado!');
        carregarMeusItens();
    } catch (erro) {
        console.error('Erro:', erro);
        alert('Erro: ' + erro.message);
    }
}
window.deletarItem = deletarItem;

document.addEventListener('DOMContentLoaded', () => {
    carregarPerfil();
    carregarMeusItens();
    carregarHistoricoTransacoes();
});