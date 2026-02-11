// Obter ID do item da URL
const urlParams = new URLSearchParams(window.location.search);
const itemId = urlParams.get('id');

// Variável para armazenar IDs originais do item
let itemOriginal = null;

async function carregarDadosItem() {
    if (!itemId) {
        alert('ID do item não encontrado');
        window.location.href = 'perfil.html';
        return;
    }

    const usuarioId = localStorage.getItem('usuario_id');
    if (!usuarioId) {
        window.location.href = 'login.html';
        return;
    }

    try {
        // Carregar dados do item
        const resItem = await fetch(`http://localhost:3000/api/itens/${itemId}`);
        const item = await resItem.json();

        console.log('Item carregado:', item);

        // Verificar se o usuário é o dono
        if (item.dono_id != usuarioId) {
            alert('Você não tem permissão para editar este item');
            window.location.href = 'perfil.html';
            return;
        }

        itemOriginal = item;

        // Carregar opções de categorias, status e estados
        await Promise.all([
            carregarCategorias(),
            carregarStatus(),
            carregarEstados()
        ]);

        // Preencher campos
        document.getElementById('nome_item').value = item.nome || '';
        document.getElementById('descricao').value = item.descricao || '';

        // Buscar os IDs para categoria, status e estado pelo valor (nome) retornado
        // Será feito após o carregamento das opções
        await preencherSelects(item);

    } catch (erro) {
        console.error('Erro ao carregar item:', erro);
        alert('Erro ao carregar dados do item');
    }
}

async function carregarCategorias() {
    try {
        const res = await fetch('http://localhost:3000/api/categorias');
        const categorias = await res.json();

        const select = document.getElementById('categoria');
        select.innerHTML = '<option value="">Selecione</option>';

        categorias.forEach(cat => {
            const option = document.createElement('option');
            option.value = cat.id_categoria;
            option.textContent = cat.tipo_categoria;
            select.appendChild(option);
        });
    } catch (erro) {
        console.error('Erro ao carregar categorias:', erro);
    }
}

async function carregarStatus() {
    try {
        const res = await fetch('http://localhost:3000/api/disponibilidades');
        const statusList = await res.json();

        const select = document.getElementById('status_item');
        select.innerHTML = '<option value="">Selecione</option>';

        statusList.forEach(status => {
            const option = document.createElement('option');
            option.value = status.id_status;
            option.textContent = status.tipo_status;
            select.appendChild(option);
        });
    } catch (erro) {
        console.error('Erro ao carregar status:', erro);
    }
}

async function carregarEstados() {
    try {
        const res = await fetch('http://localhost:3000/api/estados');
        const estados = await res.json();

        const select = document.getElementById('estado_conservacao');
        select.innerHTML = '<option value="">Selecione</option>';

        estados.forEach(estado => {
            const option = document.createElement('option');
            option.value = estado.id_estado;
            option.textContent = estado.tipo_estado;
            select.appendChild(option);
        });
    } catch (erro) {
        console.error('Erro ao carregar estados:', erro);
    }
}

async function preencherSelects(item) {
    // Aguardar que os dados estejam carregados
    await new Promise(resolve => setTimeout(resolve, 100));

    // Procurar pelo ID que corresponde ao nome retornado
    if (item.categoria) {
        const optionCategoria = Array.from(document.getElementById('categoria').options)
            .find(opt => opt.text === item.categoria);
        if (optionCategoria) {
            document.getElementById('categoria').value = optionCategoria.value;
        }
    }

    if (item.tipo) {
        const optionStatus = Array.from(document.getElementById('status_item').options)
            .find(opt => opt.text === item.tipo);
        if (optionStatus) {
            document.getElementById('status_item').value = optionStatus.value;
        }
    }

    if (item.estado) {
        const optionEstado = Array.from(document.getElementById('estado_conservacao').options)
            .find(opt => opt.text === item.estado);
        if (optionEstado) {
            document.getElementById('estado_conservacao').value = optionEstado.value;
        }
    }
}

document.getElementById('form-edicao').addEventListener('submit', async (e) => {
    e.preventDefault();

    const usuarioId = localStorage.getItem('usuario_id');
    if (!usuarioId) {
        window.location.href = 'login.html';
        return;
    }

    const nome = document.getElementById('nome_item').value.trim();
    const categoria = document.getElementById('categoria').value || null;
    const status = document.getElementById('status_item').value;
    const estado = document.getElementById('estado_conservacao').value;
    const descricao = document.getElementById('descricao').value.trim() || null;

    // Validação básica
    if (!nome) {
        alert('Nome do item é obrigatório');
        return;
    }

    if (nome.length > 100) {
        alert('Nome não pode exceder 100 caracteres');
        return;
    }

    if (!status) {
        alert('Status é obrigatório');
        return;
    }

    if (!estado) {
        alert('Estado de conservação é obrigatório');
        return;
    }

    if (descricao && descricao.length > 500) {
        alert('Descrição não pode exceder 500 caracteres');
        return;
    }

    try {
        const response = await fetch(`http://localhost:3000/api/itens/${itemId}`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                nome_item: nome,
                categoria: categoria,
                status_item: status,
                estado_conservacao: estado,
                descricao: descricao,
                dono_id: parseInt(usuarioId)
            })
        });

        const resultado = await response.json();

        if (response.ok && resultado.success) {
            alert('Item atualizado com sucesso!');
            window.location.href = `item.html?id=${itemId}`;
        } else {
            alert('Erro: ' + (resultado.error || resultado.message || 'Erro ao atualizar item'));
        }
    } catch (erro) {
        console.error('Erro ao atualizar item:', erro);
        alert('Erro ao atualizar item');
    }
});

// Carregar dados quando a página abre
document.addEventListener('DOMContentLoaded', carregarDadosItem);
