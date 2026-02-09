// Variáveis globais de controle
let conversaAtivaId = null;       // ID do Item
let outroUsuarioAtivoId = null;   // ID da pessoa com quem você fala

// --- AUTENTICAÇÃO ---
const USUARIO_LOGADO_ID = localStorage.getItem('usuario_id');

if (!USUARIO_LOGADO_ID) {
    window.location.href = 'login.html';
}

/**
 * Busca todas as conversas onde o usuário é remetente ou destinatário
 */
async function carregarConversas() {
    const sidebar = document.getElementById('lista-conversas');
    const controls = document.querySelector('.chat-controls');
    
    if (controls) controls.style.display = 'none';

    try {
        const res = await fetch(`http://localhost:3000/api/mensagens/conversas/${USUARIO_LOGADO_ID}`);
        if (!res.ok) throw new Error("Erro ao buscar conversas");

        const conversas = await res.json();
        sidebar.innerHTML = ''; 

        if (!conversas || conversas.length === 0) {
                    sidebar.innerHTML = `
                        <div style="display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 40px 20px; text-align: center; height: 100%;">

                            <img src="./src/imgs/chat.svg" alt="Sem conversas" style="width: 40px; opacity: 0.4; margin-bottom: 10px; filter: grayscale(100%);">

                            <p style="margin: 0; font-weight: 600; color: #666;">Nenhuma conversa</p>

                            <small style="color: #999; margin-top: 5px;">Suas negociações aparecerão aqui.</small>

                        </div>
                    `;
            return;
        }

        conversas.forEach(c => {
            const div = document.createElement('div');
            div.className = 'chat-preview';
            
            // Lógica para data
            const data = c.ultima_mensagem_data ? new Date(c.ultima_mensagem_data).toLocaleDateString('pt-BR') : '';

            div.innerHTML = `
                <div style="width: 100%;">
                    <div style="display: flex; justify-content: space-between;">
                        <strong>${c.nome_outro_usuario}</strong>
                        <small>${data}</small>
                    </div>
                    <p style="font-size: 0.8em; color: #666;">Item: ${c.nome_item}</p>
                </div>
            `;
            
            // Passa o item_id e o id_outro_usuario para a função de seleção
            div.onclick = () => selecionarConversa(c.item_id, c.id_outro_usuario, div);
            sidebar.appendChild(div);
        });

    } catch (err) {
        console.error("Erro na sidebar:", err);
        sidebar.innerHTML = '<p style="color:red; padding:10px;">Erro ao carregar conversas.</p>';
    }
}

/**
 * Carrega as mensagens trocadas entre os dois usuários sobre o item
 */
async function selecionarConversa(itemId, outroUsuarioId, elemento) {
    conversaAtivaId = itemId;
    outroUsuarioAtivoId = outroUsuarioId;

    // Interface
    const controls = document.querySelector('.chat-controls');
    if (controls) controls.style.display = 'flex';

    document.querySelectorAll('.chat-preview').forEach(el => el.classList.remove('active'));
    if (elemento) elemento.classList.add('active');

    const container = document.getElementById('container-mensagens');
    container.innerHTML = '<p style="text-align:center;">Carregando...</p>';

    try {
        // Chamada para a rota que criamos no server.js
        const res = await fetch(`http://localhost:3000/api/mensagens/${itemId}/${USUARIO_LOGADO_ID}/${outroUsuarioId}`);
        const mensagens = await res.json();
        
        container.innerHTML = ''; 

        mensagens.forEach(m => {
            const div = document.createElement('div');
            
            // IMPORTANTE: Use == em vez de === porque USUARIO_LOGADO_ID é string (do localStorage)
            // e m.id_remetente é número (do banco).
            div.className = (m.id_remetente == USUARIO_LOGADO_ID) ? 'msg sent' : 'msg received';
            
            const hora = new Date(m.data).toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' });

            div.innerHTML = `
                ${m.texto}
                <span style="display: block; font-size: 0.6em; text-align: right; opacity: 0.7;">${hora}</span>
            `;
            container.appendChild(div);
        });
        
        container.scrollTop = container.scrollHeight;

    } catch (err) {
        console.error("Erro ao carregar histórico:", err);
    }
}

/**
 * Envia mensagem garantindo que o destinatário correto receba
 */
async function enviarMensagem() {
    const input = document.getElementById('input-mensagem');
    const texto = input.value.trim();

    if (!texto || !conversaAtivaId || !outroUsuarioAtivoId) return;

    const payload = {
        item_id: conversaAtivaId,
        remetente_id: USUARIO_LOGADO_ID,
        destinatario_id: outroUsuarioAtivoId, // Identifica quem vai receber
        texto_mensagem: texto
    };

    try {
        const res = await fetch('http://localhost:3000/api/mensagens', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });

        if (res.ok) {
            input.value = '';
            // Atualiza o chat imediatamente
            selecionarConversa(conversaAtivaId, outroUsuarioAtivoId, document.querySelector('.chat-preview.active'));
        }
    } catch (err) {
        console.error("Erro ao enviar:", err);
    }
}

// Eventos
document.getElementById('btn-enviar').onclick = enviarMensagem;
document.getElementById('input-mensagem').onkeypress = (e) => {
    if (e.key === 'Enter') enviarMensagem();
};

window.onload = carregarConversas;