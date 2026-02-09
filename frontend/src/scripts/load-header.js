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
    const selectDisponibilidade = document.getElementById('filtro-disponibilidade');
    if (!selectDisponibilidade) return;

    const urlParams = new URLSearchParams(window.location.search);
    const buscaTermo = urlParams.get('busca');
    
    // REGRA DE OURO: Só é '1' se não houver NENHUM parâmetro na URL
    let disponibilidadeAtiva = urlParams.get('disp');
    if (disponibilidadeAtiva === null && urlParams.toString() === "") {
        disponibilidadeAtiva = '1';
    }

    try {
        const resposta = await fetch('http://localhost:3000/api/disponibilidades');
        const disponibilidades = await resposta.json();

        disponibilidades.forEach(d => {
            const option = document.createElement('option');
            option.value = d.id_disponibilidade; 
            option.textContent = d.tipo_disponibilidade; 
            
            // Compara com a regra que definimos acima
            if (d.id_disponibilidade == disponibilidadeAtiva) {
                option.selected = true;
            }
            selectDisponibilidade.appendChild(option);
        });
    } catch (err) {
        console.error("Erro ao carregar selects:", err);
    }
}

function aplicarFiltros() {
    const urlParams = new URLSearchParams(window.location.search);
    const dispVal = document.getElementById('filtro-disponibilidade').value;
    const transVal = document.getElementById('filtro-transacao').value;
    const estVal = document.getElementById('filtro-estado').value;

    // Se selecionar "Todas", removemos o parâmetro da URL completamente
    if (dispVal) {
        urlParams.set('disp', dispVal); // Se for "all", vai aparecer ?disp=all
    } else {
        urlParams.delete('disp');
    }

    if (transVal) urlParams.set('trans', transVal);
    else urlParams.delete('trans');

    if (estVal) urlParams.set('est', estVal);
    else urlParams.delete('est');

    window.location.href = `index.html?${urlParams.toString()}`;
}

function configurarBusca() {
    const input = document.querySelector('.search-bar input');
    const btn = document.querySelector('.search-btn');

    const fazerBusca = () => {
        const termo = input.value.trim();
        if (termo) {
            // Ao buscar, limpamos os filtros para garantir que o item seja achado
            window.location.href = `index.html?busca=${encodeURIComponent(termo)}`;
        } else {
            window.location.href = `index.html`;
        }
    };

    if (btn) btn.onclick = fazerBusca;
    if (input) input.onkeypress = (e) => { if (e.key === 'Enter') fazerBusca(); };
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