from flask import Flask, jsonify
import redis
import os

app = Flask(__name__)

redis_host = os.getenv('REDIS_HOST', 'localhost')
redis_port = int(os.getenv('REDIS_PORT', 6379))
redis_client = redis.Redis(host=redis_host, port=redis_port)
@app.route('/')
def home():
    try:
        # Incrementa o contador de acessos na rota raiz
        redis_client.incr('access_count')
    except redis.exceptions.ConnectionError:
        # Se o Redis estiver indisponível, a aplicação continua funcionando,
        # apenas não registra o acesso. Pode-se adicionar um log aqui se necessário.
        pass
    return 'Hello, This is My DevOps Api!'

@app.route('/health')
def health_check():
    try:
        redis_client.ping()
        return jsonify({'status': 'UP'}), 200
    except redis.exceptions.ConnectionError:
        return jsonify({'status': 'DOWN'}), 503
    
@app.route('/metrics')
def metrics():
    try:
        # Busca o valor atual do contador no Redis
        count = redis_client.get('access_count')
        # Se o contador ainda não existir (nenhum acesso à raiz), retorna 0.
        # O valor do Redis vem como bytes, então decodificamos para string e convertemos para int.
        if count is None:
            access_count = 0
        else:
            access_count = int(count.decode('utf-8'))
        return jsonify({"access_count": access_count}), 200
    except redis.exceptions.ConnectionError:
        return jsonify({"error": "Redis unavailable"}), 503
    
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)