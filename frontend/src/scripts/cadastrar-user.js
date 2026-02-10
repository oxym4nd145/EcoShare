document.getElementById('cadastroForm').addEventListener('submit', async (event) => {
    event.preventDefault();

    const dadosUsuario = {
        nome: document.getElementById('nome').value,
        email: document.getElementById('email').value,
        senha: document.getElementById('senha').value,
        data_nascimento: document.getElementById('data_nascimento').value,
        nivel_permissao: 2, 
        mensalidade_id: 1
    };

    try {
        const response = await fetch('http://localhost:3000/api/cadastrar', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(dadosUsuario)
        });

        const resultado = await response.json(); // Tenta ler direto como JSON

        if (resultado.success) {
            // 1. Mostra o modal (muda o display de 'none' para 'flex')
            const modal = document.getElementById('modalSucesso');
            modal.style.display = 'flex';

            // 2. Aguarda 4 segundos (4000ms) antes de redirecionar
            setTimeout(() => {
                window.location.href = 'login.html';
            }, 2000);

        } else {
            alert('Erro: ' + (resultado.message || 'Erro ao processar cadastro'));
        }

    } catch (error) {
        console.error('Erro de conexão:', error);
        alert('Não foi possível conectar ao servidor.');
    }
});