// Função para validar CPF
function validarCPF(cpf) {
    // Remove pontuação
    cpf = cpf.replace(/\D/g, '');
    
    // Verifica se tem 11 dígitos
    if (cpf.length !== 11) return false;
    
    // Verifica se não é uma sequência repetida
    if (/^(\d)\1{10}$/.test(cpf)) return false;
    
    // Calcula o primeiro dígito verificador
    let soma = 0;
    for (let i = 0; i < 9; i++) {
        soma += parseInt(cpf[i]) * (10 - i);
    }
    let resto = soma % 11;
    let digito1 = resto < 2 ? 0 : 11 - resto;
    
    if (parseInt(cpf[9]) !== digito1) return false;
    
    // Calcula o segundo dígito verificador
    soma = 0;
    for (let i = 0; i < 10; i++) {
        soma += parseInt(cpf[i]) * (11 - i);
    }
    resto = soma % 11;
    let digito2 = resto < 2 ? 0 : 11 - resto;
    
    if (parseInt(cpf[10]) !== digito2) return false;
    
    return true;
}

// Máscara para CPF (000.000.000-00)
document.getElementById('cpf').addEventListener('input', (e) => {
    let value = e.target.value.replace(/\D/g, '');
    if (value.length > 11) value = value.slice(0, 11);
    
    if (value.length <= 3) {
        e.target.value = value;
    } else if (value.length <= 6) {
        e.target.value = value.slice(0, 3) + '.' + value.slice(3);
    } else if (value.length <= 9) {
        e.target.value = value.slice(0, 3) + '.' + value.slice(3, 6) + '.' + value.slice(6);
    } else {
        e.target.value = value.slice(0, 3) + '.' + value.slice(3, 6) + '.' + value.slice(6, 9) + '-' + value.slice(9);
    }
});

// Máscara para CEP (00000-000)
document.getElementById('cep').addEventListener('input', (e) => {
    let value = e.target.value.replace(/\D/g, '');
    if (value.length > 8) value = value.slice(0, 8);
    
    if (value.length <= 5) {
        e.target.value = value;
    } else {
        e.target.value = value.slice(0, 5) + '-' + value.slice(5);
    }
});

document.getElementById('cadastroForm').addEventListener('submit', async (event) => {
    event.preventDefault();

    // Pega os valores do formulário
    const nome = document.getElementById('nome').value.trim();
    const cpf = document.getElementById('cpf').value.trim();
    const email = document.getElementById('email').value.trim();
    const senha = document.getElementById('senha').value;
    const data_nascimento = document.getElementById('data_nascimento').value;
    const cep = document.getElementById('cep').value.trim();
    const logradouro = document.getElementById('logradouro').value.trim();
    const numero = document.getElementById('numero').value.trim();
    const bairro = document.getElementById('bairro').value.trim();
    const cidade = document.getElementById('cidade').value.trim();
    const estado = document.getElementById('estado').value.toUpperCase().trim();

    // === VALIDAÇÕES DE CAMPOS VAZIOS ===
    if (!nome || nome.length === 0) {
        alert('Nome é obrigatório');
        return;
    }

    if (!email || email.length === 0) {
        alert('Email é obrigatório');
        return;
    }

    if (!senha || senha.length === 0) {
        alert('Senha é obrigatória');
        return;
    }

    if (!data_nascimento) {
        alert('Data de nascimento é obrigatória');
        return;
    }

    // === VALIDAÇÕES DE COMPRIMENTO ===
    if (nome.length > 150) {
        alert('Nome não pode ter mais de 150 caracteres');
        return;
    }

    if (email.length > 150) {
        alert('Email não pode ter mais de 150 caracteres');
        return;
    }

    if (senha.length < 6) {
        alert('Senha deve ter pelo menos 6 caracteres');
        return;
    }

    if (senha.length > 100) {
        alert('Senha não pode ter mais de 100 caracteres');
        return;
    }

    if (logradouro.length > 255) {
        alert('Logradouro não pode ter mais de 255 caracteres');
        return;
    }

    if (numero.length > 20) {
        alert('Número não pode ter mais de 20 caracteres');
        return;
    }

    if (bairro.length > 100) {
        alert('Bairro não pode ter mais de 100 caracteres');
        return;
    }

    if (cidade.length > 100) {
        alert('Cidade não pode ter mais de 100 caracteres');
        return;
    }

    // === VALIDAÇÕES DE FORMATO ===
    // Email
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
        alert('Email inválido');
        return;
    }

    // Validar CPF
    if (!validarCPF(cpf)) {
        alert('CPF inválido. Por favor, verifique o número informado.');
        return;
    }

    // Validar CEP
    if (!/^\d{5}-\d{3}$/.test(cep)) {
        alert('CEP inválido. Use o formato: 00000-000');
        return;
    }

    // Validar UF
    if (estado.length !== 2 || !/^[A-Z]{2}$/.test(estado)) {
        alert('Estado deve ter exatamente 2 letras maiúsculas (ex: SP, RJ)');
        return;
    }

    // Validar Data de Nascimento
    if (!/^\d{4}-\d{2}-\d{2}$/.test(data_nascimento)) {
        alert('Data de nascimento inválida');
        return;
    }

    const dadosUsuario = {
        nome: nome,
        email: email,
        senha: senha,
        data_nascimento: data_nascimento,
        documento: cpf.replace(/\D/g, ''),
        cep: cep,
        logradouro: logradouro,
        numero: numero,
        bairro: bairro,
        cidade: cidade,
        estado: estado,
        nivel_permissao: 2, 
        mensalidade_id: 1
    };

    try {
        const response = await fetch('http://localhost:3000/api/cadastrar', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(dadosUsuario)
        });

        const resultado = await response.json();

        if (resultado.success) {
            const modal = document.getElementById('modalSucesso');
            modal.style.display = 'flex';

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