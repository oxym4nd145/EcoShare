const form = document.getElementById('loginForm');
const msgErro = document.getElementById('msgErro');

form.addEventListener('submit', async (e) => {
    e.preventDefault();
    
    const email = document.getElementById('email').value;
    const senha = document.getElementById('senha').value;
    const btn = document.querySelector('.btn-entrar');

    // Feedback visual
    btn.innerText = 'Verificando...';
    btn.disabled = true;
    msgErro.style.display = 'none';

    try {
        const response = await fetch('http://localhost:3000/api/login', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email, senha }) // Envia senha para comparar com hash_senha
        });

        const data = await response.json();

        if (data.success) {
            // SUCESSO: Salva ID e Nome no navegador
            localStorage.setItem('usuario_id', data.id);
            localStorage.setItem('usuario_nome', data.nome);
            
            // Redireciona para a home
            window.location.href = 'index.html';
        } else {
            // ERRO: Mostra mensagem
            msgErro.innerText = data.error || 'Erro ao entrar.';
            msgErro.style.display = 'block';
        }

    } catch (error) {
        console.error(error);
        msgErro.innerText = 'Erro de conexão com o servidor.';
        msgErro.style.display = 'block';
    } finally {
        btn.innerText = 'ENTRAR';
        btn.disabled = false;
    }
});