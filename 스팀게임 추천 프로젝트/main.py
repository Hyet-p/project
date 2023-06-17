import sqlite3
import pandas as pd
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.metrics.pairwise import cosine_similarity
import pickle
import warnings
warnings.filterwarnings("ignore")

'''
1. 데이터 불러오기
'''
# 데이터베이스에 연결
conn = sqlite3.connect('steamDB')

# 쿼리를 실행하여 데이터를 가져옵니다.
df = pd.read_sql_query("SELECT * from df_final", conn)

conn.close()  # 데이터베이스 연결을 종료합니다.

# 데이터 확인
#df.head()

'''
2. category, genre 유일값 확인
'''

# 세미콜론으로 연결된 데이터를 분리하여 리스트로 변환
split_categories = df['category'].str.split(';')

# 리스트의 리스트로 변환된 데이터를 하나의 리스트로 통합
flat_cat = [item for sublist in split_categories for item in sublist]

# 리스트의 모든 유일한 값을 찾음
unique_categories = list(set(flat_cat))

#print(unique_categories)

# 세미콜론으로 연결된 데이터를 분리하여 리스트로 변환
split_genres = df['genre'].str.split(';')

# 리스트의 리스트로 변환된 데이터를 하나의 리스트로 통합
flat_gen = [item for sublist in split_genres for item in sublist]

# 리스트의 모든 유일한 값을 찾음
unique_genres = list(set(flat_gen))

#print(unique_genres)

'''
3. 머신러닝 - 유사도 계산
'''

# categories와 genres 합치기
df['combined_features'] = df['category'] + ';' + df['genre']

# 토크나이징 함수
def tokenize(text):
    return text.split(';')
"""
# CountVectorizer를 이용하여 combined_features에 대한 matrix 생성
cv = CountVectorizer(tokenizer=tokenize)
count_matrix = cv.fit_transform(df['combined_features'])

# cosine similarity matrix 생성
cosine_sim = cosine_similarity(count_matrix)

# pickle로 저장
with open('cv.pkl', 'wb') as f:
    pickle.dump(cv, f)

with open('count_matrix.pkl', 'wb') as f:
    pickle.dump(count_matrix, f)
"""
def recommend_games(categories, genres, price):
    user_features = ';'.join(categories + genres)

    # Load CountVectorizer from pickle
    with open('cv.pkl', 'rb') as f:
        cv = pickle.load(f)

    # user_feature에 대한 벡터 생성
    user_vector = cv.transform([user_features])

    # Load count_matrix from pickle
    with open('count_matrix.pkl', 'rb') as f:
        count_matrix = pickle.load(f)
    
    # 유사도 계산
    cosine_sim_user = cosine_similarity(count_matrix, user_vector)

    # 유사도에 따라 게임들을 정렬
    sim_scores = list(enumerate(cosine_sim_user))
    sim_scores = sorted(sim_scores, key=lambda x: x[1], reverse=True)

    # 가장 유사한 게임들의 인덱스를 가져옴
    game_indices = [i[0] for i in sim_scores]

    # 가장 유사한 게임들 중 price 이하인 것들을 선택하고, 상위 5개만 남김
    recommended_games = df['name'].iloc[game_indices]
    recommended_games = recommended_games[df['price'] <= price]
    recommended_games = recommended_games[:5]

    return recommended_games

#print(recommend_games(['Single-player'],['Indie'], 15000))