import matplotlib.pyplot as plt
import numpy as np
import psycopg2

def main():
    try:
        conn = psycopg2.connect("dbname='postgres' user='postgres' host='localhost' password='********'")
    except:
        print("I am unable to connect to the database")

    cur = conn.cursor()
    # queries - collborators and pubs
    queries = {
        '# Collaborators':
            '''
            SELECT Number_Collaborators, COUNT(a_id) AS Author_Count
                FROM (SELECT a_id, COUNT(DISTINCT y) AS Number_Collaborators
                          FROM Col_Authors
                          GROUP BY a_id) AS Number_Collabs
                GROUP BY Number_Collaborators
                ORDER BY Number_Collaborators;
            ''',
        '# Publications':
            '''      
            SELECT Number_Publications, COUNT(AuthorID) AS Number_Authors
                FROM (SELECT AuthorID, COUNT(PubID) AS Number_Publications
                          FROM Authored
                          GROUP BY AuthorID) AS AuthorPub
                GROUP BY Number_Publications
                ORDER BY Number_Publications;
            '''
    }
    fig, ax = plt.subplots(2, 1)
    plt.subplots_adjust(hspace=1)
    for i, (name, query) in enumerate(queries.items()):
        cur.execute(query)
        rows = cur.fetchall()

        x = [r[0] for r in rows]
        y = np.log([r[1] for r in rows])
        ax[i].plot(x, y)
        ax[i].set_title('Distribution of ' + name)
        ax[i].set_xlabel(name)
        ax[i].set_ylabel('# Authors')

    file = 'graph.pdf'
    plt.savefig(file)
    print('file saved: %s' % file)


if __name__ == '__main__':
    main()