console.log('load-header.js carregado!');

async function gerenciarInterfaceUsuario() {
    const usuarioId = localStorage.getItem('usuario_id');
    const textoBoasVindas = document.getElementById('boas-vindas');
    const btnLogout = document.getElementById('btn-logout');
    const linkAnunciar = document.getElementById('link-anunciar');

    // Se não houver elementos no HTML, para aqui para não dar erro
    if (!textoBoasVindas || !btnLogout || !linkAnunciar) return;

    if (!usuarioId) {
        // Estado: Deslogado
        textoBoasVindas.innerText = 'Olá, visitante';
        btnLogout.style.display = 'none';
        linkAnunciar.style.display = 'none';
        return; 
    }

    try {
        const resposta = await fetch(`http://localhost:3000/api/usuario/completo/${usuarioId}`);
        const user = await resposta.json();

        if (user && user.nome_usuario) {
            textoBoasVindas.innerText = `Olá, ${user.nome_usuario}`;
            btnLogout.style.display = 'flex'; // Certifique-se que o CSS não oculte o botão
            linkAnunciar.style.display = 'flex';
        }
    } catch (erro) {
        console.error("Erro ao buscar dados do usuário:", erro);
        // Mesmo com erro na API, se tem ID, mostramos o botão de sair
        textoBoasVindas.innerText = 'Olá, Usuário';
        btnLogout.style.display = 'flex';
        linkAnunciar.style.display = 'flex';
    }
}

async function carregarCategoriasHeader() {
    const selectCategoria = document.getElementById('filtro-categoria');
    if (!selectCategoria) return;

    const urlParams = new URLSearchParams(window.location.search);
    const catAtiva = urlParams.get('cat');

    try {
        const resposta = await fetch('http://localhost:3000/api/categorias');
        const categorias = await resposta.json();

        // Limpa as opções existentes (exceto a primeira "Todas")
        selectCategoria.innerHTML = '<option value="">Todas Categorias</option>';

        categorias.forEach(cat => {
            const option = document.createElement('option');
            option.value = cat.id_categoria; // Use o nome da coluna do seu banco (id_categoria)
            option.textContent = cat.tipo_categoria;
            
            if (catAtiva == cat.id_categoria) {
                option.selected = true;
            }
            selectCategoria.appendChild(option);
        });
    } catch (erro) {
        console.error("Erro ao carregar categorias no select:", erro);
    }
}

// Filtros removidos por enquanto - vamos refazer quando houver necessidade

async function inicializarFiltros() {
    // Pega os valores atuais da URL
    const urlParams = new URLSearchParams(window.location.search);
    const estAtivo = urlParams.get('est');
    const dispAtiva = urlParams.get('disp');

    // Popula Estados
    const selectEstado = document.getElementById('filtro-estado');
    if (selectEstado) {
        try {
            const resEst = await fetch('http://localhost:3000/api/estados');
            const estados = await resEst.json();
            console.log('Estados carregados:', estados);

            // Limpa e reconstrói opções
            selectEstado.innerHTML = '<option value="">Todos Estados</option>';

            estados.forEach(e => {
                const option = document.createElement('option');
                option.value = e.id_estado;
                option.textContent = e.tipo_estado;
                
                // Restaura seleção anterior se existir
                if (estAtivo && estAtivo == e.id_estado) {
                    option.selected = true;
                }
                
                selectEstado.appendChild(option);
            });
        } catch (err) {
            console.error('Erro ao carregar estados:', err);
        }
    }

    // Popula Disponibilidades
    const selectDisponibilidade = document.getElementById('filtro-disponibilidade');
    if (selectDisponibilidade) {
        try {
            const resDisp = await fetch('http://localhost:3000/api/disponibilidades');
            const disponibilidades = await resDisp.json();
            console.log('Disponibilidades carregadas:', disponibilidades);

            // Limpa e reconstrói opções
            selectDisponibilidade.innerHTML = '<option value="">Todas Disponibilidades</option>';

            disponibilidades.forEach(d => {
                const option = document.createElement('option');
                option.value = d.id_status;
                option.textContent = d.tipo_status;
                
                // Restaura seleção anterior se existir
                if (dispAtiva && dispAtiva == d.id_status) {
                    option.selected = true;
                }
                
                selectDisponibilidade.appendChild(option);
            });
        } catch (err) {
            console.error('Erro ao carregar disponibilidades:', err);
        }
    }
}

function aplicarFiltros() {
    const urlParams = new URLSearchParams(window.location.search);
    
    const catVal = document.getElementById('filtro-categoria').value;
    const estVal = document.getElementById('filtro-estado').value;
    const dispVal = document.getElementById('filtro-disponibilidade').value;

    console.log('Filtros aplicados:', { cat: catVal, est: estVal, disp: dispVal });

    if (catVal) {
        urlParams.set('cat', catVal);
    } else {
        urlParams.delete('cat');
    }

    if (estVal) {
        urlParams.set('est', estVal);
    } else {
        urlParams.delete('est');
    }

    if (dispVal) {
        urlParams.set('disp', dispVal);
    } else {
        urlParams.delete('disp');
    }

    // Preserva a busca se existir
    const busca = urlParams.get('busca');
    if (busca) urlParams.set('busca', busca);

    console.log('URL final:', urlParams.toString());
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
    inicializarFiltros();
    configurarBusca();
    gerenciarInterfaceUsuario();
});