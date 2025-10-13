"""SEG-Analise-de-Sistemas/app.py"""

from datetime import datetime
from flask import Flask, render_template, request, redirect
from flask_sqlalchemy import SQLAlchemy


app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///petshop_db.db'
db = SQLAlchemy(app)


# Definição do Modelo
class CLIENTE(db.Model):
    """Cria a tablea de clientes"""
    id_cliente = db.Column(db.Integer, primary_key=True)
    nome = db.Column(db.String(100), nullable=False)
    telefone = db.Column(db.String(15), unique=True, nullable=False)
    email = db.Column(db.String(100), unique=True)
    cpf = db.Column(db.String(14), unique=True)
    data_cadastro = db.Column(db.DateTime(), default=datetime.now)

# cRud - Read (ler)
@app.route('/')
def index():
    clientes = CLIENTE.query.all()
    return render_template('index.html', clientes=clientes)

# Crud - Create (criar)
@app.route('/create', methods=['POST'])
def create_cliente():
    nome = request.form['nome']
    telefone = request.form['telefone']
    email = request.form['email']
    cpf = request.form['cpf']

    # Valida se o cliente já está cadastrado
    existe_cliente_telefone = CLIENTE.query.filter_by(telefone=telefone).first()
    existe_cliente_email = CLIENTE.query.filter_by(email=email).first()
    existe_cliente_cpf = CLIENTE.query.filter_by(cpf=cpf).first()

    if (existe_cliente_telefone or existe_cliente_email or existe_cliente_cpf):
        return 'ERRO: Cliente já Cadastrado!', 400

    novo_cliente = CLIENTE(nome=nome, telefone=telefone, email=email, cpf=cpf)
    db.session.add(novo_cliente)
    db.session.commit()

    return redirect('/')

# cruD - Delete (apagar)
@app.route('/delete/<int:id_cliente>', methods=['POST'])
def delete_cliente(id_cliente):
    cliente = CLIENTE.query.get(id_cliente)
    if cliente:
        db.session.delete(cliente)
        db.session.commit()
    return redirect('/')

# crUd - Update (atualizar)
@app.route('/update/<int:id_cliente>', methods=['POST'])
def update_cliente(id_cliente):
    cliente = CLIENTE.query.get(id_cliente)
    if cliente:
        cliente.nome = request.form['nome']
        cliente.telefone = request.form['telefone']
        cliente.email = request.form['email']
        cliente.cpf = request.form['cpf']
        db.session.commit()
    return redirect('/')

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(debug=True, port=5153)
