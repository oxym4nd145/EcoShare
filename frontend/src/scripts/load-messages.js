let conversaAtivaId = null;
const USUARIO_LOGADO_ID = 1; // Exemplo: ID do utilizador atual

async function carregarConversas() {
    try {
        const res = await fetch(`http://localhost:3000/api/mensagens/conversas/${USUARIO_LOGADO_ID}`);
        const conversas = await res.json();
        
        const sidebar = document.getElementById('lista-conversas');
        sidebar.innerHTML = '';

        conversas.forEach(c => {
            const div = document.createElement('div');
            div.className = 'chat-preview';
            div.innerHTML = `
                <strong>${c.nome_outro_usuario}</strong>
                <p>Item: ${c.nome_item}</p>
            `;
            div.onclick = () => selecionarConversa(c.id_conversa, div);
            sidebar.appendChild(div);
        });
    } catch (err) {
        console.error("Erro ao carregar conversas:", err);
    }
}

async function selecionarConversa(id, elemento) {
    conversaAtivaId = id;
    
    // Estilo visual de "ativo" na sidebar
    document.querySelectorAll('.chat-preview').forEach(el => el.classList.remove('active'));
    elemento.classList.add('active');

    const res = await fetch(`http://localhost:3000/api/mensagens/${id}`);
    const mensagens = await res.json();
    
    const container = document.getElementById('container-mensagens');
    container.innerHTML = '';

    mensagens.forEach(m => {
        const div = document.createElement('div');
        // Define se a mensagem fica à esquerda ou direita
        div.className = m.id_remetente === USUARIO_LOGADO_ID ? 'msg sent' : 'msg received';
        div.innerText = m.texto;
        container.appendChild(div);
    });
    
    container.scrollTop = container.scrollHeight; // Desce o scroll
}

// Lógica de Envio
document.getElementById('btn-enviar').onclick = async () => {
    const input = document.getElementById('input-mensagem');
    if (!input.value || !conversaAtivaId) return;

    const novaMsg = {
        id_conversa: conversaAtivaId,
        id_remetente: USUARIO_LOGADO_ID,
        texto: input.value
    };

    try {
        await fetch('http://localhost:3000/api/mensagens', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(novaMsg)
        });

        input.value = '';
        selecionarConversa(conversaAtivaId, document.querySelector('.chat-preview.active'));
    } catch (err) {
        alert("Erro ao enviar mensagem.");
    }
};

window.onload = carregarConversas;