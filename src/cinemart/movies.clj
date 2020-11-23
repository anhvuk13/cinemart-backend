(ns cinemart.movies
  (:require [ring.util.http-response :as res]
            [cinemart.db :as db]))

(defn get-movies [_]
  (res/ok {:movies (db/get-movies db/config)}))

(defn get-movie-by-id
  [{:keys [parameters]}]
  (let [id (:path parameters)
        movie (db/get-movie-by-id db/config id)]
    (if movie
      (res/ok {:movie movie})
      (res/not-found {:error "Movie not found"}))))

(defn create-movie [{:keys [parameters]}]
  (let [movie (-> (:body parameters)
                  (db/insert-movie db/config)
                  (db/get-movie-by-id db/config))]
    (res/created
     (str "/movie/" (:id movie))
     {:movie movie})))

(defn update-movie
  [{:keys [parameters]}]
  (let [id (get-in parameters [:path :id])
        movie (assoc (:body parameters) :id id)
        updated-count (db/update-movie-by-id db/config movie)]
    (if (= 1 updated-count)
      (res/ok {:updated true
               :movie (db/get-movie-by-id db/config {:id id})})
      (res/not-found
       {:updated false
        :error "Unable to update movie"}))))

(defn delete-movie
  [{:keys [parameters]}]
  (let [id (:path parameters)
        before-deleted (db/get-movie-by-id db/config id)
        deleted-count (db/delete-movie-by-id db/config id)]
    (if (= 1 deleted-count)
      (res/ok
       {:deleted true
        :movie before-deleted})
      (res/not-found
       {:deleted false
        :error "Unable to delete movie"}))))
