document.addEventListener('DOMContentLoaded', () => {
    const usuarioId = localStorage.getItem('usuario_id');
    if (!usuarioId) {
        window.location.href = 'login.html';
        return;
    }

    const form = document.getElementById('form-anuncio');
    const msg = document.getElementById('form-msg');
    const selectCategoria = document.getElementById('categoria');
    const selectStatus = document.getElementById('status_item');
    const selectEstado = document.getElementById('estado_conservacao');

    const setMessage = (text, type = 'error') => {
        msg.textContent = text;
        msg.className = `form-msg ${type}`;
    };

    const carregarCategorias = async () => {
        try {
            const res = await fetch('http://localhost:3000/api/categorias');
            const categorias = await res.json();
            selectCategoria.innerHTML = '<option value="">Selecione</option>';
            categorias.forEach(cat => {
                const opt = document.createElement('option');
                opt.value = cat.id_categoria;
                opt.textContent = cat.tipo_categoria;
                selectCategoria.appendChild(opt);
            });
        } catch (err) {
            console.error('Erro ao carregar categorias:', err);
            setMessage('Não foi possível carregar categorias.', 'error');
        }
    };

    const carregarStatus = async () => {
        try {
            const res = await fetch('http://localhost:3000/api/disponibilidades');
            const status = await res.json();
            selectStatus.innerHTML = '<option value="">Selecione</option>';
            status.forEach(s => {
                const opt = document.createElement('option');
                opt.value = s.id_status;
                opt.textContent = s.tipo_status;
                selectStatus.appendChild(opt);
            });
        } catch (err) {
            console.error('Erro ao carregar status:', err);
            setMessage('Não foi possível carregar status.', 'error');
        }
    };

    const carregarEstados = async () => {
        const fallbackEstados = [
            { id_estado: '1', tipo_estado: 'Novo' },
            { id_estado: '2', tipo_estado: 'Usado' },
            { id_estado: '3', tipo_estado: 'Reformado' }
        ];

        try {
            const res = await fetch('http://localhost:3000/api/estados');
            const estados = await res.json();
            const data = estados && estados.length ? estados : fallbackEstados;
            selectEstado.innerHTML = '<option value="">Selecione</option>';
            data.forEach(e => {
                const opt = document.createElement('option');
                opt.value = e.id_estado;
                opt.textContent = e.tipo_estado;
                selectEstado.appendChild(opt);
            });
        } catch (err) {
            console.error('Erro ao carregar estados:', err);
            selectEstado.innerHTML = '<option value="">Selecione</option>';
            fallbackEstados.forEach(e => {
                const opt = document.createElement('option');
                opt.value = e.id_estado;
                opt.textContent = e.tipo_estado;
                selectEstado.appendChild(opt);
            });
        }
    };

    form.addEventListener('submit', async (e) => {
        e.preventDefault();
        setMessage('');

        const nome_item = document.getElementById('nome_item').value.trim();
        const categoria = selectCategoria.value || null;
        const status_item = selectStatus.value;
        const estado_conservacao = selectEstado.value;
        const descricao = document.getElementById('descricao').value.trim() || null;

        if (!nome_item || !status_item || !estado_conservacao) {
            setMessage('Preencha os campos obrigatórios.', 'error');
            return;
        }

        try {
            const res = await fetch('http://localhost:3000/api/itens', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    dono_id: usuarioId,
                    nome_item,
                    categoria,
                    status_item,
                    descricao,
                    estado_conservacao
                })
            });

            const data = await res.json().catch(() => ({}));
            if (!res.ok) throw new Error(data.error || 'Erro ao anunciar item');

            setMessage('Item anunciado com sucesso!', 'success');
            form.reset();
        } catch (err) {
            console.error(err);
            setMessage(err.message || 'Erro ao anunciar item', 'error');
        }
    });

    carregarCategorias();
    carregarStatus();
    carregarEstados();
});
