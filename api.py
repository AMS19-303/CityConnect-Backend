import flask
from flask import Flask, request, jsonify
import psycopg2
import psycopg2.extras
import datetime

app = Flask(__name__)
app.config['JSON_SORT_KEYS'] = False

conn = psycopg2.connect(host='localhost',user='postgres',dbname='cityconnect_db')

@app.route("/")
def index():
    return "CityConnect database API v1"

@app.route("/stores")
def stores():
    cat = request.args.getlist('category')
    return get_stores(category=cat)

@app.route("/categories")
def categories():
    global conn
    if conn:
        cur = conn.cursor()
        cur.execute("SELECT category_id as id, name, food FROM category")
        return jsonify([dict(zip([d[0] for d in cur.description],row)) for row in cur.fetchall()])
    return jsonify([])

@app.route("/catalog")
def catalog():
    global conn
    store = request.args.get('store')
    
    if conn and store:
        cur = conn.cursor()
        cur.execute("SELECT p.name, p.description, p.base_unit, p.unit, p.unit_price FROM product AS p WHERE p.store_id = %s" % store)
        return jsonify([dict(zip([d[0] for d in cur.description],row)) for row in cur.fetchall()])
    return jsonify([])

def db_close():
    global conn
    if conn:
        conn.close()

def get_stores(category=[]):
    global conn
    if conn:
        cur = conn.cursor()
        if not category:
            cur.execute("SELECT DISTINCT ON (s.store_id) s.store_id AS id, s.name, s.type, s.photo, s.gps FROM store AS s")
        elif len(category)==1:
            cur.execute("SELECT DISTINCT ON (s.store_id) s.store_id AS id, s.name, s.type, s.photo, s.gps FROM store AS s, category_store AS cs, category AS c WHERE cs.store_id = s.store_id AND cs.category_id = c.category_id " \
            + ("AND cs.category_id = %d" % int(category[0])))
        else:  
            cur.execute("SELECT DISTINCT ON (s.store_id) s.store_id AS id, s.name, s.type, s.photo, s.gps FROM store AS s, category_store AS cs, category AS c WHERE cs.store_id = s.store_id AND cs.category_id = c.category_id " \
            + "AND cs.category_id IN %s" % str(tuple(category)))
        res = []
        columns = [d[0] for d in cur.description]
        for row in cur.fetchall():
            entry = dict(zip(columns,row))
            cur.execute("SELECT day_of_week, open, close FROM business_hours WHERE business_hours.store_id = %s" % entry['id'])
            bh = []
            cols = [d[0] for d in cur.description]
            for d,o,c in cur.fetchall():
                o = o.strftime("%H:%M:%S")
                c = c.strftime("%H:%M:%S")
                bh.append(dict(zip(cols,(d,o,c))))
            entry['business_hours'] = bh
            cur.execute("SELECT c.name FROM category_store AS cs, category AS c, store AS s WHERE cs.category_id = c.category_id AND cs.store_id = s.store_id AND s.store_id = %s" % entry['id'])
            cat = []
            cols = [d[0] for d in cur.description]
            for name in cur.fetchall():
                cat.append(name[0])
            entry['categories'] = cat
            res.append(entry)
        if not res:
            return jsonify([])
        return jsonify(res)
    return jsonify([])


if __name__ == "__main__":
    app.run(host='localhost', port=80)