async function gerenciarInterfaceUsuario() {
    const usuarioId = localStorage.getItem('usuario_id');
    const textoBoasVindas = document.getElementById('boas-vindas');
    const btnLogout = document.getElementById('btn-logout');

    // Se não houver elementos no HTML, para aqui para não dar erro
    if (!textoBoasVindas || !btnLogout) return;

    if (!usuarioId) {
        // Estado: Deslogado
        textoBoasVindas.innerText = 'Olá, visitante';
        btnLogout.style.display = 'none';
        return; 
    }

    try {
        const resposta = await fetch(`http://localhost:3000/api/usuario/completo/${usuarioId}`);
        const user = await resposta.json();

        if (user && user.nome_usuario) {
            textoBoasVindas.innerText = `Olá, ${user.nome_usuario}`;
            btnLogout.style.display = 'flex'; // Certifique-se que o CSS não oculte o botão
        }
    } catch (erro) {
        console.error("Erro ao buscar dados do usuário:", erro);
        // Mesmo com erro na API, se tem ID, mostramos o botão de sair
        textoBoasVindas.innerText = 'Olá, Usuário';
        btnLogout.style.display = 'flex';
    }
}

async function carregarCategoriasHeader() {
    const navGroup = document.getElementById('categorias-nav');
    if (!navGroup) return; 

    // 1. Obtém o ID da categoria que está na URL atual
    const urlParams = new URLSearchParams(window.location.search);
    const categoriaAtiva = urlParams.get('cat');

    try {
        const resposta = await fetch('http://localhost:3000/api/categorias');
        const categorias = await resposta.json();

        navGroup.innerHTML = '<span class="sub-nav-label">Categorias:</span>';

        categorias.forEach(cat => {
            const link = document.createElement('a');
            link.classList.add('categoria-text');
            link.href = `index.html?cat=${cat.id_categoria}`;
            link.textContent = cat.tipo_categoria;

            // 2. Compara o ID do link com o ID da URL
            // Usamos == (dois iguais) porque um pode ser string e outro número
            if (categoriaAtiva == cat.id_categoria) {
                link.style.fontWeight = 'bold';
                link.style.textDecoration = 'underline'; // Opcional: ajuda a destacar mais
                link.style.color = 'var(--primary-green)'; // Garante que fique visível
            }

            navGroup.appendChild(link);
        });

    } catch (erro) {
        console.error("Erro ao carregar categorias:", erro);
    }
}

async function carregarFiltrosSelect() {
    const selectTransacao = document.getElementById('filtro-transacao');
    const selectDisponibilidade = document.getElementById('filtro-disponibilidade');
    const selectEstado = document.getElementById('filtro-estado');

    // Se os elementos não existirem no HTML, para a execução
    if (!selectTransacao || !selectDisponibilidade || !selectEstado) return;

    // 1. Verificar o que já está selecionado na URL
    const urlParams = new URLSearchParams(window.location.search);
    const transacaoAtiva = urlParams.get('trans');
    const disponibilidadeAtiva = urlParams.get('disp') === null ? '1' : urlParams.get('disp');
    const estadoAtivo = urlParams.get('est');

    try {
        // 2. Buscar dados do backend
        const [resTransacao, resDisponibilidade, resEstado] = await Promise.all([
            fetch('http://localhost:3000/api/transacoes'),
            fetch('http://localhost:3000/api/disponibilidades'),
            fetch('http://localhost:3000/api/estados')
        ]);

        // Verificação extra de erro na requisição
        if (!resTransacao.ok) console.error("Erro ao buscar transações");
        if (!resDisponibilidade.ok) console.error("Erro ao buscar disponibilidades");
        if (!resEstado.ok) console.error("Erro ao buscar estados");

        const transacoes = await resTransacao.json();
        const disponibilidades = await resDisponibilidade.json();
        const estados = await resEstado.json();

        // 3. Preencher Select de Transação
        transacoes.forEach(d => {
            const option = document.createElement('option');

            const valorId = d.id_transacao_tipo || d.id_transacao || d.id; 
            const texto = d.tipo_transacao || d.nome;

            option.value = valorId; 
            option.textContent = texto; 
            
            if (valorId == transacaoAtiva) {
                option.selected = true;
            }
            selectTransacao.appendChild(option);
        });

        disponibilidades.forEach(d => {
            const option = document.createElement('option');

            const valorId = d.id_disponibilidade; 
            const texto = d.tipo_disponibilidade || d.nome;

            option.value = valorId; 
            option.textContent = texto; 
            
            if (valorId == disponibilidadeAtiva) {
                option.selected = true;
            }
            selectDisponibilidade.appendChild(option);
        });

        // 4. Preencher Select de Estado
        estados.forEach(e => {
            const option = document.createElement('option');
            
            // Ajuste aqui se o nome da coluna no banco for diferente
            const valorId = e.id_estado; 
            const texto = e.tipo_estado;

            option.value = valorId; 
            option.textContent = texto;
            
            if (valorId == estadoAtivo) {
                option.selected = true;
            }
            selectEstado.appendChild(option);
        });

    } catch (err) {
        console.error("Erro ao carregar filtros do select:", err);
    }
}

/**
 * Função chamada pelo onchange="" no HTML
 * Ela pega os valores e recarrega a página com os novos parâmetros URL
 */
function aplicarFiltros() {
    const transacaoVal = document.getElementById('filtro-transacao').value;
    const disponibilidadeVal = document.getElementById('filtro-disponibilidade').value;
    const estadoVal = document.getElementById('filtro-estado').value;
    
    // Pega a URL atual e seus parâmetros existentes (ex: categoria)
    const urlParams = new URLSearchParams(window.location.search);

    // Atualiza ou remove o parâmetro de Transação
    if (transacaoVal) {
        urlParams.set('trans', transacaoVal);
    } else {
        urlParams.delete('trans');
    }

    if (disponibilidadeVal) {
        urlParams.set('disp', disponibilidadeVal);
    } else {
        urlParams.set('est', ''); 
    }

    // Atualiza ou remove o parâmetro de Estado
    if (estadoVal) {
        urlParams.set('est', estadoVal);
    } else {
        urlParams.delete('est');
    }

    // Recarrega a página com a nova URL filtrada
    window.location.href = `index.html?${urlParams.toString()}`;
}

// Tornar a função global para o HTML conseguir enxergar (necessário em alguns setups de módulo)
window.aplicarFiltros = aplicarFiltros;

function configurarBusca() {
    const input = document.querySelector('.search-bar input');
    const btn = document.querySelector('.search-btn');

    if (!input || !btn) return;

    const fazerBusca = () => {
        const termo = input.value.trim();
        const params = new URLSearchParams(window.location.search);
        if (termo) params.set('busca', termo);
        else params.delete('busca');
        window.location.href = `index.html?${params.toString()}`;
    };

    btn.onclick = fazerBusca;
    input.onkeypress = (e) => { if (e.key === 'Enter') fazerBusca(); };
}

window.fazerLogout = function() {
    localStorage.removeItem('usuario_id');
    window.location.href = 'login.html';
};

document.addEventListener('DOMContentLoaded', () => {
    carregarCategoriasHeader();
    carregarFiltrosSelect();
    configurarBusca();
    gerenciarInterfaceUsuario();
});