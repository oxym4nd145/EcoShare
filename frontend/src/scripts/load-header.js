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

async function carregarFiltrosSelect() {
    const selectDisponibilidade = document.getElementById('filtro-disponibilidade');
    const selectEstado = document.getElementById('filtro-estado');
    const selectTransacao = document.getElementById('filtro-transacao');
    const selectUf = document.getElementById('filtro-uf');
    
    if (!selectDisponibilidade || !selectEstado || !selectTransacao || !selectUf) return;
    
    // 1. Pega os valores atuais da URL
    const urlParams = new URLSearchParams(window.location.search);
    const catAtiva = urlParams.get('cat');
    const dispAtiva = urlParams.get('disp');
    const estAtivo = urlParams.get('est');
    const transAtiva = urlParams.get('trans');
    const ufAtivo = urlParams.get('uf');
    
    // --- UFs (Estados brasileiros) ---
    // Popula as 27 UFs no select separado (filtro-uf)
    const ufs = [
        { sigla: 'AC', nome: 'Acre' },{ sigla: 'AL', nome: 'Alagoas' },{ sigla: 'AP', nome: 'Amapá' },
        { sigla: 'AM', nome: 'Amazonas' },{ sigla: 'BA', nome: 'Bahia' },{ sigla: 'CE', nome: 'Ceará' },
        { sigla: 'DF', nome: 'Distrito Federal' },{ sigla: 'ES', nome: 'Espírito Santo' },{ sigla: 'GO', nome: 'Goiás' },
        { sigla: 'MA', nome: 'Maranhão' },{ sigla: 'MT', nome: 'Mato Grosso' },{ sigla: 'MS', nome: 'Mato Grosso do Sul' },
        { sigla: 'MG', nome: 'Minas Gerais' },{ sigla: 'PA', nome: 'Pará' },{ sigla: 'PB', nome: 'Paraíba' },
        { sigla: 'PR', nome: 'Paraná' },{ sigla: 'PE', nome: 'Pernambuco' },{ sigla: 'PI', nome: 'Piauí' },
        { sigla: 'RJ', nome: 'Rio de Janeiro' },{ sigla: 'RN', nome: 'Rio Grande do Norte' },{ sigla: 'RS', nome: 'Rio Grande do Sul' },
        { sigla: 'RO', nome: 'Rondônia' },{ sigla: 'RR', nome: 'Roraima' },{ sigla: 'SC', nome: 'Santa Catarina' },
        { sigla: 'SP', nome: 'São Paulo' },{ sigla: 'SE', nome: 'Sergipe' },{ sigla: 'TO', nome: 'Tocantins' }
    ];

    selectUf.innerHTML = '<option value="all">Todas UFs</option>';
    ufs.forEach(u => {
        const opt = document.createElement('option');
        opt.value = u.sigla;
        opt.textContent = `${u.nome} (${u.sigla})`;
        if (ufAtivo && ufAtivo.toUpperCase() === u.sigla) opt.selected = true;
        selectUf.appendChild(opt);
    });

    // --- Disponibilidades (Status_tipo) ---
    try {
        const resDisp = await fetch('http://localhost:3000/api/disponibilidades');
        const disponibilidades = await resDisp.json();

        selectDisponibilidade.innerHTML = '<option value="all">Todas Disponibilidades</option>';

        const temParametros = window.location.search.length > 0;

        disponibilidades.forEach(d => {
            const option = document.createElement('option');
            option.value = d.id_status;
            option.textContent = d.tipo_status;
            
            // Se o ID está na URL, marca como selecionado
            if (dispAtiva == d.id_status) {
                option.selected = true;
            }
            
            // SÓ entra aqui se o usuário digitou o endereço do site puro, sem clicar em nada
            if (!temParametros && d.id_status == 1) {
                option.selected = true;
            }

            selectDisponibilidade.appendChild(option);
        });
    } catch (err) {
        console.error("Erro ao carregar disponibilidades:", err);
    }

    // --- Estados (Estado_tipo) ---
    // Mantém a opção padrão "Todos Estados" antes de popular via API
    selectEstado.innerHTML = '<option value="all">Todos Estados</option>';

    // Fallback estático caso a API falhe ou retorne vazio
    const fallbackEstados = [
        { id_estado: '1', tipo_estado: 'Novo' },
        { id_estado: '2', tipo_estado: 'Usado' },
        { id_estado: '3', tipo_estado: 'Reformado' }
    ];

    let estados = [];
    try {
        const resEst = await fetch('http://localhost:3000/api/estados');
        estados = await resEst.json();
    } catch (e) {
        console.warn('Não foi possível carregar estados da API, usando fallback estático.', e);
        estados = fallbackEstados;
    }

    if (!estados || estados.length === 0) estados = fallbackEstados;

    estados.forEach(e => {
        const option = document.createElement('option');
        option.value = e.id_estado;
        option.textContent = e.tipo_estado;

        // Mantém selecionado se for o ID da URL
        if (estAtivo == e.id_estado) {
            option.selected = true;
        }
        selectEstado.appendChild(option);
    });

    // --- Transações ---
    try {
        const resTrans = await fetch('http://localhost:3000/api/transacoes');
        const trans = await resTrans.json();

        trans.forEach(t => {
            const option = document.createElement('option');
            
            // CORREÇÃO: O nome da coluna no seu SQL é id_transacao_tipo
            option.value = t.id_transacao_tipo; 
            option.textContent = t.tipo_transacao;

            // Comparação com o parâmetro da URL
            if (transAtiva == t.id_transacao_tipo) {
                option.selected = true;
            }
            selectTransacao.appendChild(option);
        });
    } catch (err) {
        console.error("Erro ao carregar transações:", err);
    }
}

function aplicarFiltros() {
    const urlParams = new URLSearchParams(window.location.search);
    
    const catVal = document.getElementById('filtro-categoria').value;
    const transVal = document.getElementById('filtro-transacao').value;
    const estVal = document.getElementById('filtro-estado').value;
    const ufVal = document.getElementById('filtro-uf') ? document.getElementById('filtro-uf').value : null;
    const dispVal = document.getElementById('filtro-disponibilidade').value;

    // Lógica para Categoria, Transação e Estado:
    // Se estiver vazio ou for "all", removemos da URL para mantê-la limpa
    if (catVal && catVal !== "all") urlParams.set('cat', catVal);
    else urlParams.delete('cat');

    if (transVal && transVal !== "all") urlParams.set('trans', transVal);
    else urlParams.delete('trans');

    if (estVal && estVal !== "all") urlParams.set('est', estVal);
    else urlParams.delete('est');

    if (ufVal && ufVal !== "all") urlParams.set('uf', ufVal);
    else urlParams.delete('uf');

    // Lógica para Disponibilidade:
    // Mantemos o "all" na URL apenas se o usuário escolheu "Todas" 
    // para evitar o gatilho de "primeiro acesso" que força o ID 1
    if (dispVal === "all") {
        urlParams.set('disp', 'all');
    } else if (dispVal) {
        urlParams.set('disp', dispVal);
    } else {
        urlParams.delete('disp');
    }

    // Preserva a busca se existir
    const busca = urlParams.get('busca');
    if (busca) urlParams.set('busca', busca);

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