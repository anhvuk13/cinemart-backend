(ns cinemart.movies
  (:require [ring.util.http-response :as res]
            [cinemart.db :as db]))

(defn get-movies [_]
  (res/ok {:response (db/get-movies db/config)}))

(defn get-movie-by-id
  [{:keys [parameters]}]
  (let [id (:path parameters)
        movie (db/get-movie-by-id db/config id)]
    (if movie
      (res/ok {:response movie})
      (res/not-found {:error "movie not found"}))))

(defn create-movie [{:keys [parameters]}]
  (let [movie (-> (:body parameters)
                  ((partial db/insert-movie db/config)))]
    (res/created
     (str "/movies/" (:id movie))
     {:response movie})))

(defn update-movie
  [{:keys [parameters]}]
  (let [id (:path parameters)
        before-updated (db/get-movie-by-id db/config id)
        movie (merge before-updated (:body parameters))
        updated-count (db/update-movie-by-id db/config movie)]
    (if (= 1 updated-count)
      (res/ok {:updated true
               :response {:before-updated before-updated
                          :after-updated movie}})
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

(get-movie-by-id {:parameters {:path {:id 2}}})
