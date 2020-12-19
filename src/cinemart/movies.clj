(ns cinemart.movies
  (:require [ring.util.http-response :as res]
            [cinemart.services :as s]
            [cinemart.db :as db]))

(defn get-movies [_]
  (res/ok {:response
           (db/get-movies db/config)}))

(defn get-movie-by-id
  [{:keys [parameters]}]
  (let [id (:path parameters)
        movie (db/get-movie-by-id db/config id)]
    (if movie
      (res/ok {:response movie})
      (res/not-found {:error "movie not found"}))))

(defn get-movies-from-now [_]
  (res/ok {:response {:month (db/get-movies-this-month db/config)
                      :week (db/get-movies-this-week db/config)
                      :day (db/get-movies-this-day db/config)}}))

(defn get-movies-from-now-by-theater [{:keys [parameters]}]
  (let [id (:path parameters)]
    (res/ok {:response {:all (db/get-movies-by-theater db/config id)
                        :month (db/get-movies-this-month-by-theater db/config id)
                        :week (db/get-movies-this-week-by-theater db/config id)
                        :day (db/get-movies-this-day-by-theater db/config id)}})))

(defn insert-movie [{:keys [parameters]} insert-db]
  (let [movie (-> (:body parameters)
                  ((partial insert-db db/config)))]
    (res/created
     (str "/movies/" (:id movie))
     {:response movie})))

(defn get-movies-of-each-genre [_]
  (let [genres (db/get-genres db/config)
        movies
        (map
          (fn [{:keys [id]}]
            (db/get-movies-by-genre db/config {:id id}))
          genres)]
    (res/ok {:response {:genres genres
                        :movies movies}})))

(defn create-movie [req]
  (insert-movie req db/insert-movie))

(defn draw-movie [req]
  (let [id (get-in req [:parameters :body :id])
        movie (db/get-movie-by-id db/config {:id id})]
    (if movie
      (res/bad-request {:error (str "id " id " already exists")})
      (insert-movie req db/draw-movie))))

(defn update-movie
  [{:keys [parameters old-data]}]
  (let [movie (:body parameters)
        updated-count (db/update-movie-by-id db/config movie)]
    (if (= 1 updated-count)
      (res/ok {:updated true
               :response {:before-updated old-data
                          :after-updated (db/get-movie-by-id db/config movie)}})
      (res/not-found
        {:updated false
         :error "unable to update movie"}))))

(defn delete-movie
  [{:keys [parameters]}]
  (let [id (:path parameters)
        before-deleted (db/get-movie-by-id db/config id)
        deleted-count (db/delete-movie-by-id db/config id)]
    (if (= 1 deleted-count)
      (res/ok
       {:deleted true
        :response {:before-deleted before-deleted}})
      (res/not-found
       {:deleted false
        :error "unable to delete movie"}))))
