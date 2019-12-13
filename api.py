from flask import Flask, request, jsonify
import psycopg2.extras

app = Flask(__name__)
app.config['JSON_SORT_KEYS'] = False

conn = psycopg2.connect(host='localhost', user='postgres', dbname='cityconnect_db')
if not conn:
    print("Error on connection to database, quitting...")
    quit(1)

# TODO: ORDER-SPECIFIC INSERT/UPDATE API CALLS (partially done)
# TODO: COURIER-SPECIFIC API CALLS


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
        return jsonify([dict(zip([d[0] for d in cur.description], row)) for row in cur.fetchall()])
    return jsonify([])


@app.route("/orders")
def orders():
    global conn
    arglst = request.args.getlist()
    if arglst and ["active", "id"] not in arglst.keys():
        return jsonify([])
    active = bool(arglst["active"])
    user_id = int(arglst["id"])
    cur = conn.cursor()
    cur.execute("SELECT * FROM order WHERE user_id = %s and active = %s" % (user_id, active))
    return jsonify([dict(zip([d[0] for d in cur.description], row)) for row in cur.fetchall()])


# TODO: verify if user is a courier; if it is, return courier information along with the standard user info
@app.route("/order", methods=['GET', 'POST'])
def order():
    global conn

    cur = conn.cursor()
    if request.method == 'GET':
        active = request.args.get('active')
        res = get_orders(active)

        for d in res:
            cur.execute("SELECT * FROM order_item WHERE order_id = '%s'" % (d['order_id'],))
            items = []
            cols = [d[0] for d in cur.description]

            for row in cur.fetchall():
                entry = dict(zip(cols, row))
                pid = entry['product_id']

                if pid:
                    cur.execute(f"SELECT p.product_id AS id, p.name, p.type, p.description, p.store_id, p.unit_price, p.base_unit, p.unit FROM product AS p"
                                + " WHERE p.product_id = %s" % (pid,))
                    prod_cols = [d[0] for d in cur.description]
                    res_p = [dict(zip(prod_cols, row)) for row in cur.fetchall()]

                    cur.execute("SELECT name FROM store WHERE store_id = %s" % (res_p[0]['store_id'],))
                    name = str(cur.fetchone())
                    res_p[0]['store_name'] = eval(name)[0]

                    entry['product'] = res_p[0]
                else:
                    entry['product_id'] = None
                items.append(entry)
            d['items'] = items

            if active == 'false':
                cur.execute("SELECT * FROM courier WHERE courier_id = %s" % (d['courier_id'], ))
                res_courier = [dict(zip([d[0] for d in cur.description], row)) for row in cur.fetchall()]

                cur.execute("SELECT * FROM public.user WHERE user_id = %s" % (res_courier[0]['user_id'],))
                res_user_c = [dict(zip([d[0] for d in cur.description], row)) for row in cur.fetchall()]

                res_courier[0]['user'] = res_user_c[0]
                d['courier'] = res_courier[0]
            elif active == 'true':
                d['courier'] = None
        return jsonify(res)
    else:
        data = request.get_json()
        uid = data['user_id']
        active = data['active']
        total_price = data['total_price']

        lst_items = data['items']

        cur.execute("INSERT INTO order (user_id, active, total_price) VALUES (%s, %s, %s)" % (uid, active, total_price))
        oid = cur.lastrowid

        for item in lst_items:
            quant = item['quantity']
            price = item['cumul_price']
            discount = item['discount']
            pid = item['product_id']

            cur.execute("INSERT INTO order_item (quantity, cumul_price, discount, product_id, order_id)"
                        + " VALUES (%s, %s, %s, %s, %s)" % (quant, price, discount, pid, oid))


@app.route("/profile")
def profile():
    global conn
    uid = request.args.get('id', -1, int)
    if uid == -1:
        return jsonify([])
    cur = conn.cursor()
    cur.execute("SELECT * FROM public.user WHERE user_id = %s" % (uid,))

    res = [dict(zip([d[0] for d in cur.description], row)) for row in cur.fetchall()]

    cur.execute("SELECT * FROM courier WHERE user_id = %s" % (res[0]['user_id'],))
    cour_res = cur.fetchall()
    if cour_res:
        res[0]['courier'] = [dict(zip([d[0] for d in cur.description], row)) for row in cour_res]
    else:
        res[0]['courier'] = None
    return jsonify(res)

# TODO: PAYMENT WITH ORDER ID!
@app.route("/payment")
def payment():
    global conn
    return jsonify([])


@app.route("/catalog")
def catalog():
    global conn
    store = request.args.get('store')

    if conn and store:
        cur = conn.cursor()
        cur.execute(
            "SELECT p.product_id, p.name, p.description, p.base_unit, p.unit, p.unit_price FROM product AS p WHERE p.store_id = %s" % (store,))
        return jsonify([dict(zip([d[0] for d in cur.description], row)) for row in cur.fetchall()])
    return jsonify([])


# TODO: LOGIN API CALL
@app.route("/sin")
def login():
    global conn
    return jsonify([])

# TODO: LOGOUT API CALL (LOGOUT REQUESTED BY USER)
@app.route("/sout")
def logout():
    global conn
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
            cur.execute(
                "SELECT DISTINCT ON (s.store_id) s.store_id AS id, s.name, s.type, s.photo, s.gps FROM store AS s")
        elif len(category) == 1:
            cur.execute(
                "SELECT DISTINCT ON (s.store_id) s.store_id AS id, s.name, s.type, s.photo, s.gps FROM store AS s, category_store AS cs, category AS c WHERE cs.store_id = s.store_id AND cs.category_id = c.category_id "
                + "AND cs.category_id = %s" % (int(category[0]),))
        else:
            cur.execute(
                "SELECT DISTINCT ON (s.store_id) s.store_id AS id, s.name, s.type, s.photo, s.gps FROM store AS s, category_store AS cs, category AS c WHERE cs.store_id = s.store_id AND cs.category_id = c.category_id "
                + f"AND cs.category_id IN %s" % (str(tuple(category)),))
        res = []
        columns = [d[0] for d in cur.description]
        for row in cur.fetchall():
            entry = dict(zip(columns, row))
            if 'gps' in entry.keys():
                entry['gps'] = list(eval(entry['gps']))
            cur.execute(
                "SELECT day_of_week, open, close FROM business_hours WHERE business_hours.store_id = %s" % (entry['id'],))
            bh = []
            cols = [d[0] for d in cur.description]
            for d, o, c in cur.fetchall():
                o = o.strftime("%H:%M:%S")
                c = c.strftime("%H:%M:%S")
                bh.append(dict(zip(cols, (d, o, c))))
            entry['business_hours'] = bh
            cur.execute(
                "SELECT c.name FROM category_store AS cs, category AS c, store AS s WHERE cs.category_id = c.category_id AND cs.store_id = s.store_id AND s.store_id = %s" % (entry['id'],))
            cat = []
            for name in cur.fetchall():
                cat.append(name[0])
            entry['categories'] = cat
            res.append(entry)
        if not res:
            return jsonify([])
        return jsonify(res)
    return jsonify([])


def get_orders(active='true'):
    global conn
    if active not in ['true', 'false']:
        return []
    cur = conn.cursor()
    cur.execute("SELECT * FROM public.order WHERE active = '%s'" % (active,))
    res = [dict(zip([d[0] for d in cur.description], row)) for row in cur.fetchall()]
    for d in res:
        d['timestamp'] = d['timestamp'].strftime("%Y-%m-%d %H:%M:%S")
    return res


if __name__ == "__main__":
    try:
        app.run(host='', port=80)
    except KeyboardInterrupt:
        pass
    finally:
        db_close()
        print("Goodbye!")
        quit(0)
