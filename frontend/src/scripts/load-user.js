function formatarClasse(texto) {
    if (!texto) return 'default';
    return texto
        .toLowerCase()               // 1. Tudo minúsculo
        .normalize('NFD')            // 2. Separa os acentos das letras
        .replace(/[\u0300-\u036f]/g, "") // 3. Remove os acentos
        .replace(/\s+/g, '-')        // 4. Troca ESPAÇOS por TRAÇOS
        .trim();                     // 5. Remove espaços extras nas pontas
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
        const resposta = await fetch(`http://localhost:3000/api/usuario/completo/${USUARIO_ID}`);
        const user = await resposta.json();

        // Foto de perfil
        const imgElement = document.getElementById('user-foto'); // Verifique o ID no perfil.html
        if (user.endereco_cdn) {
            imgElement.src = user.endereco_cdn; 
        } else {
            imgElement.src = 'src/imgs/user-gray.svg'; // Imagem padrão caso o banco retorne nulo
        }

        // 1. Preenchimento de Informações Básicas
        setElementText('user-nome', user.nome_usuario);
        setElementText('user-email', user.email);
        
        // 2. Badge de Mensalidade com Estilização Dinâmica
        const badgeMensalidade = document.getElementById('user-mensalidade-badge');
        if (badgeMensalidade) {
            badgeMensalidade.innerText = user.tipo_mensalidade || 'Grátis';
            
            if (user.tipo_mensalidade?.toLowerCase() === 'plus') {
                badgeMensalidade.style.backgroundColor = 'var(--accent-gold)';
                badgeMensalidade.style.color = 'var(--text-dark)';
            }
        }

        // 3. Dados Financeiros (Formatação de Moeda)
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

        setElementText('user-tipo-pessoa', user.nome_tipo_pessoa);
        setElementText('user-cep', user.cep || 'Não informado');

        // 5. Endereço
        setElementText('user-logradouro', user.logradouro || '...');
        setElementText('user-numero', user.numero || 'S/N');
        setElementText('user-bairro', user.bairro || '...');
        setElementText('user-cidade', user.cidade || '...');
        setElementText('user-uf', user.estado || '..');

        // 6. RENDERIZAÇÃO DAS TRANSAÇÕES
        // Passamos o array de transações que vem da API (ou um array vazio se não existir)
        renderizarTransacoes(user.transacoes || []);

    } catch (error) {
        console.error("Erro ao carregar perfil:", error);

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

        container.innerHTML = itens.map(item => `
            <a href="item.html?id=${item._id}" class="product-card">
                <div class="img-container">
                    <img src="${item.foto || './src/imgs/recycle-sign.svg'}" alt="${item.nome}">
                </div>
                <div class="card-info">
                    <span class="badge type-${formatarClasse(item.tipo)}">
                        ${item.tipo}
                    </span>
                    <h3>${item.nome}</h3>
                </div>
            </a>
        `).join('');

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

document.addEventListener('DOMContentLoaded', () => {
    carregarPerfil();
    carregarMeusItens();
    carregarHistoricoTransacoes();
});