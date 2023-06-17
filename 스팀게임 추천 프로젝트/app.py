from flask import Flask, render_template, request
from main import unique_categories, unique_genres, tokenize, recommend_games
import pandas as pd
import pickle

app = Flask(__name__)


# Load the pickled objects
with open('cv.pkl', 'rb') as f:
    cv = pickle.load(f)

with open('count_matrix.pkl', 'rb') as f:
    count_matrix = pickle.load(f)


@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        categories = request.form.getlist('categories')
        genres = request.form.getlist('genres')
        price = int(request.form.get('price'))
        recommendations = recommend_games(categories, genres, price)
    else:
        # 첫 화면이 로드될 때 'recommendations' 변수를 빈 DataFrame으로 초기화
        recommendations = pd.DataFrame()

    return render_template('index.html', categories=unique_categories, genres=unique_genres, recommendations=recommendations)

if __name__ == '__main__':
    app.run(debug=True)

# $env:FLASK_APP="project/app.py"
# python app.py