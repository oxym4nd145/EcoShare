// Variáveis globais de controle
let conversaAtivaId = null;       // ID do Item
let outroUsuarioAtivoId = null;   // ID da pessoa com quem você fala

// --- AUTENTICAÇÃO ---
const usuarioLogadoObj = JSON.parse(localStorage.getItem('usuario_logado'));
const USUARIO_LOGADO_ID = usuarioLogadoObj ? usuarioLogadoObj.id : localStorage.getItem('usuario_id');

if (!USUARIO_LOGADO_ID) {
    console.error("Usuário não logado!");
    window.location.href = 'login.html';
}

/**
 * Busca todas as conversas onde o usuário é remetente ou destinatário
 */
async function carregarConversas() {
    const sidebar = document.getElementById('lista-conversas');
    const controls = document.querySelector('.chat-controls');
    
    if (controls && !conversaAtivaId) {
        controls.style.display = 'none';
    }

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
            
            // Verifica se esta conversa é a que está aberta no momento
            if (c.item_id == conversaAtivaId && c.id_outro_usuario == outroUsuarioAtivoId) {
                div.classList.add('active');
            }

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
async function selecionarConversa(itemId, outroUsuarioId, elemento, ehSilencioso = false) {
    conversaAtivaId = itemId;
    outroUsuarioAtivoId = outroUsuarioId;

    // Interface: Mostra os controles de input
    const controls = document.querySelector('.chat-controls');
    if (controls) controls.style.display = 'flex';

    // Destaque visual na sidebar
    document.querySelectorAll('.chat-preview').forEach(el => el.classList.remove('active'));
    if (elemento) elemento.classList.add('active');

    const container = document.getElementById('container-mensagens');
    container.innerHTML = '<div class="loading">Carregando histórico...</div>';

    if (!ehSilencioso) {
        container.innerHTML = '<div class="loading">Carregando histórico...</div>';
    }

    try {
        const res = await fetch(`http://localhost:3000/api/mensagens/${itemId}/${USUARIO_LOGADO_ID}/${outroUsuarioId}`);
        const mensagens = await res.json();
        
        container.innerHTML = ''; 

        if (mensagens.length === 0) {
            container.innerHTML = `
                <div style="text-align:center; margin-top:20px; color:#999;">
                    <p>Inicie uma conversa sobre este item!</p>
                </div>`;
        } else {
            mensagens.forEach(m => {
                const div = document.createElement('div');
                div.className = (m.id_remetente == USUARIO_LOGADO_ID) ? 'msg sent' : 'msg received';
                
                const hora = new Date(m.data).toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' });

                div.innerHTML = `
                    <div class="bubble">
                        ${m.texto}
                        <span style="display: block; font-size: 0.6em; text-align: right; opacity: 0.7; margin-top:4px;">${hora}</span>
                    </div>
                `;
                container.appendChild(div);
            });
        }
        
        setTimeout(() => {
            container.scrollTop = container.scrollHeight;
        }, 100);

        // Opcional: Limpa a URL para não ficar com ?item=... o tempo todo
        window.history.replaceState({}, document.title, "mensagens.html");

    } catch (err) {
        console.error("Erro ao carregar histórico:", err);
        container.innerHTML = '<p style="color:red; text-align:center;">Erro ao carregar mensagens.</p>';
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
        destinatario_id: outroUsuarioAtivoId,
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
            
            // 1. Atualiza o histórico de forma "silenciosa" (sem apagar a tela)
            await selecionarConversa(conversaAtivaId, outroUsuarioAtivoId, null, true);
            
            // 2. Recarrega a sidebar (que agora não vai mais esconder os botões)
            await carregarConversas();
        }
    } catch (err) {
        console.error("Erro ao enviar:", err);
    }
}

async function carregarChatAutomatico() {
    const urlParams = new URLSearchParams(window.location.search);
    const itemId = urlParams.get('item');
    const donoId = urlParams.get('dono');
    const usuarioLogado = JSON.parse(localStorage.getItem('usuario_logado'));

    if (itemId && donoId && usuarioLogado) {
        const usuarioLogadoId = usuarioLogado.id_usuario;

        try {
            const res = await fetch(`http://localhost:3000/api/mensagens/${itemId}/${usuarioLogadoId}/${donoId}`);
            const historico = await res.json();

            // Chame sua função que desenha as mensagens na tela
            renderizarMensagens(historico);
            
            // Dica: Guarde esses IDs em variáveis globais ou campos ocultos 
            // para saber para quem enviar o POST depois
            window.chatAtual = { itemId, donoId };
        } catch (erro) {
            console.error("Erro ao carregar chat inicial:", erro);
        }
    }
}

document.addEventListener('DOMContentLoaded', async () => {
    const urlParams = new URLSearchParams(window.location.search);
    const itemIdUrl = urlParams.get('item');
    const donoIdUrl = urlParams.get('dono');

    await carregarConversas();

    // Valida se os parâmetros da URL existem e não são "undefined" em texto
    if (itemIdUrl && donoIdUrl && donoIdUrl !== 'undefined') {
        conversaAtivaId = itemIdUrl;
        outroUsuarioAtivoId = donoIdUrl;

        console.log("Chat validado:", { conversaAtivaId, outroUsuarioAtivoId });

        // Abre a conversa
        selecionarConversa(conversaAtivaId, outroUsuarioAtivoId, null);
    } else {
        console.warn("Aviso: Parâmetros de chat inválidos ou ausentes na URL.");
    }
});

// Eventos de envio
document.getElementById('btn-enviar').onclick = enviarMensagem;
document.getElementById('input-mensagem').onkeypress = (e) => {
    if (e.key === 'Enter') enviarMensagem();
};