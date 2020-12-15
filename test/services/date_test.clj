(ns services.date_test
  (:require [clojure.test :refer :all]
            [clj-time.core :as t]
            [clj-time.coerce :as c]
            [clj-time.format :as f]
            [cinemart.services :as s])
  (:import java.util.Date))

(deftest test-parse-int
  (testing "result parse-int"
    (is (t/equal? (c/from-date (java.util.Date.)) (t/now)))

    (is (= (.getTime (java.util.Date.)) (c/to-long (t/now))))

    (is (= (s/now) (.getTime (java.util.Date.))))

    (is (= (s/now) (c/to-long (t/now))))))

