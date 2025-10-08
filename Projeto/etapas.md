# Implementação de CRUD de Clientes com Flask

## Requisitos

**Ferramentas:**

  * [cite\_start]VS Code [cite: 1]
      * **Extensões:**
          * [cite\_start]SQLite [cite: 1]
          * [cite\_start]SQLite Viewer [cite: 2]
          * [cite\_start]SQLite3 Editor [cite: 2]
          * [cite\_start]Live Server [cite: 2]
          * [cite\_start]Python [cite: 3]
  * [cite\_start]Python [cite: 3]
  * [cite\_start]DB Browser [cite: 3]

**Bibliotecas:**

  * flask
  * flask-sqlalchemy

-----

## Etapas

1.  **Crie o arquivo `app.py`**

2.  **Instale o Flask:**

    ```bash
    pip install flask
    ```

3.  **Instale o Flask-SQLAlchemy:**

    ```bash
    pip install flask-sqlalchemy
    ```

4.  **Importe o Flask:**

    ```python
    from flask import Flask
    ```

5.  **Crie a aplicação Flask:**

    ```python
    app = Flask(__name__)
    ```

6.  **Crie a rota padrão:**

    ```python
    @app.route('/')
    def index():
        return 'Olá Mundo!'
    ```

7.  [cite\_start]**Crie o inicializador do servidor:** [cite: 4]

    ```python
    if __name__ == '__main__':
        app.run(debug=True, port=5153)
    ```

8.  **Importe o `render_template` do Flask:**

    ```python
    from flask import Flask, render_template
    ```

9.  **Crie a pasta `templates`**

10. **Crie o arquivo `index.html` na pasta `templates`**

11. **Altere a rota padrão para incluir o `render_template`:**

    ```python
    @app.route('/')
    def index():
        return render_template('index.html')
    ```

12. **No arquivo `index.html`, crie o HTML padrão:**

      * `html lang="pt-BR"`
      * `title: PetShop`
      * Crie um `<h1>PetShop Au Au</h1>`

13. [cite\_start]**Aprendendo a interação do Python com HTML:** [cite: 5]
    a. [cite\_start]Crie uma lista simples: [cite: 6]

    ```python
    clientes = ['cliente 1', 'cliente 2', 'cliente 3', 'cliente 4']
    ```

    b. [cite\_start]Inclua os clientes como parâmetro no `render_template` da rota padrão. [cite: 7]

14. [cite\_start]**No arquivo `index.html`, renderize os clientes criando um laço de repetição Jinja:** [cite: 8]

    ```html
    <h2>Clientes Cadastrados</h2>
    <ul>
        {% for cliente in clientes %}
            <li>{{ cliente }}</li>
        {% endfor %}
    </ul>
    ```

15. **Compreendida a interação do Python com HTML, passaremos a verificar a interação do Python com o banco de dados.**

16. [cite\_start]**Importe a biblioteca `flask_sqlalchemy`:** [cite: 9]

    ```python
    from flask_sqlalchemy import SQLAlchemy
    ```

17. **Instancie o Banco de Dados:**

    ```python
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///petshop_db.db'
    db = SQLAlchemy(app)
    ```

    *O sistema cria automaticamente a pasta `instances` por padrão.*

18. **Crie a classe para gerenciar a tabela `CLIENTE`:**

    ```python
    class CLIENTE(db.Model):
        id_cliente = db.Column(db.Integer, primary_key=True, autoincrement=True)
        nome = db.Column(db.String(100), nullable=False)
        [cite_start]telefone = db.Column(db.String(15), unique=True, nullable=False) [cite: 10]
        email = db.Column(db.String(100), unique=True)
        cpf = db.Column(db.String(14), unique=True)
        data_cadastro = db.Column(db.DateTime(), default=datetime.datetime.now)
    ```

    *Lembre-se de importar a biblioteca `datetime`.*

19. **Atualize o inicializador do servidor para criar o banco de dados:**

    ```python
    with app.app_context():
        db.create_all()
    ```

-----

## Implementação do CRUD

### 1\. Read (Ler)

a. [cite\_start]Na rota padrão, altere a variável e insira a consulta: [cite: 11]

```python
clientes = CLIENTE.query.all()
```

b. [cite\_start]Verifique o resultado na página. [cite: 12]
c. [cite\_start]Para visualizar os dados, modifique o objeto no `index.html`: [cite: 13]

```html
{{ cliente.nome }}
```

### 2\. Create (Criar)

a. [cite\_start]Importe os métodos `request` e `redirect` do Flask. [cite: 14]

```python
from flask import Flask, render_template, request, redirect
```

b. [cite\_start]Implemente a rota para criar um novo cliente: [cite: 15]

```python
@app.route('/create', methods=['POST'])
```

c. [cite\_start]Crie a função `create_cliente`: [cite: 16]

```python
def create_cliente():
```

d. [cite\_start]Faça a ligação dos dados com o formulário: [cite: 17]

```python
nome = request.form['nome']
telefone = request.form['telefone']
email = request.form['email']
cpf = request.form['cpf']
```

e. [cite\_start]Crie a variável `novo_cliente`: [cite: 18]

```python
novo_cliente = CLIENTE(nome=nome, telefone=telefone, email=email, cpf=cpf)
```

f. [cite\_start]Abra uma sessão para adicionar o cliente no banco de dados: [cite: 19]

```python
db.session.add(novo_cliente)
```

g. [cite\_start]Confirme a alteração no banco de dados com um commit: [cite: 20]

```python
db.session.commit()
```

h. [cite\_start]Finalize redirecionando para a página inicial: [cite: 21]

```python
return redirect('/')
```

#### 2.1 Atualizando o `index.html` com o formulário

Adicione o formulário no arquivo `index.html`:

```html
<h2>Adicionar Novo Cliente</h2>
[cite_start]<form action="/create" method="POST"> [cite: 22]
    <input type="text" name="nome" placeholder="Nome" required>
    <input type="text" name="telefone" placeholder="Telefone" required>
    <input type="text" name="email" placeholder="E-mail">
    <input type="text" name="cpf" placeholder="CPF">
    <button type="submit">Cadastrar Cliente</button>
[cite_start]</form> [cite: 22]
```

#### 2.2 Tratamento de erro de integridade

Para evitar erros ao cadastrar um cliente com dados duplicados, adicione uma validação:

```python
# Valida se o cliente já está cadastrado
existe_cliente_telefone = CLIENTE.query.filter_by(telefone=telefone).first()
existe_cliente_email = CLIENTE.query.filter_by(email=email).first()
[cite_start]existe_cliente_cpf = CLIENTE.query.filter_by(cpf=cpf).first() [cite: 23]

if (existe_cliente_telefone or existe_cliente_email or existe_cliente_cpf):
    return 'ERRO: Cliente já Cadastrado!', 400
```

### 3\. Delete (Apagar)

a. [cite\_start]Implemente a rota para deletar um cliente: [cite: 24]

```python
@app.route('/delete/<int:id_cliente>', methods=['POST'])
```

b. [cite\_start]Crie a função para deletar o cliente: [cite: 25]

```python
def delete_cliente(id_cliente):
```

c. [cite\_start]Procure o cliente no banco de dados pelo ID: [cite: 26]

```python
cliente = CLIENTE.query.get(id_cliente)
```

d. [cite\_start]Verifique se o cliente existe e, em caso positivo, faça a exclusão: [cite: 27]

```python
if cliente:
    db.session.delete(cliente)
    db.session.commit()
```

#### 3.1 Atualizando o `index.html` para o Delete

Modifique a lista de clientes para incluir o botão de exclusão:

```html
<ul>
    {% for cliente in clientes %}
        <li>
            {{ cliente.nome }}
            [cite_start]<form action="/delete/{{ cliente.id_cliente }}" method="POST" style="display: inline;"> [cite: 28]
                <button type="submit">Excluir</button>
            </form>
        </li>
    {% endfor %}
</ul>
```

### 4\. Update (Atualizar)

a. [cite\_start]Implemente a rota para atualizar um cliente: [cite: 29]

```python
@app.route('/update/<int:id_cliente>', methods=['POST'])
```

b. [cite\_start]Crie a função para atualizar o cliente: [cite: 30]

```python
def update_cliente(id_cliente):
```

c. [cite\_start]Procure o cliente no banco de dados pelo ID: [cite: 31]

```python
cliente = CLIENTE.query.get(id_cliente)
```

d. [cite\_start]Verifique se o cliente existe e, em caso positivo, faça a atualização: [cite: 32]

```python
if cliente:
    cliente.nome = request.form['nome']
    cliente.telefone = request.form['telefone']
    cliente.cpf = request.form['cpf']
    db.session.commit()
```

#### 4.1 Atualizando o `index.html` para o Update

Atualize a lista para incluir os campos de atualização e o botão de exclusão:

```html
<ul style="list-style: none;">
    {% for cliente in clientes %}
        [cite_start]<li> [cite: 33]
            [cite_start]<form action="/update/{{ cliente.id_cliente }}" method="POST" style="display: inline;"> [cite: 33]
                <input type="text" name="nome" value="{{ cliente.nome }}">
                <input type="text" name="telefone" value="{{ cliente.telefone }}">
                [cite_start]<input type="text" name="email" value="{{ cliente.email }}"> [cite: 34]
                <input type="text" name="cpf" value="{{ cliente.cpf }}">
                <button type="submit">Atualizar</button>
            </form>

            <form action="/delete/{{ cliente.id_cliente }}" method="POST" style="display: inline;">
                [cite_start]<button type="submit">Excluir</button> [cite: 35]
            </form>
        </li>
    {% endfor %}
</ul>
```