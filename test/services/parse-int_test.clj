(ns services.parse-int_test
  (:require [clojure.test :refer :all]
            [cinemart.services :refer [parse-int]]))

(deftest test-parse-int
  (testing "result parse-int"
    (is (= (parse-int "0") 0))

    (is (= (parse-int "-999") -999))

    (is (= (parse-int "1") 1))

    (is (nil? (parse-int " 1 ")))

    (is (nil? (parse-int "1 ")))

    (is (nil? (parse-int "[1]")))

    (is (nil? (parse-int "{1}")))

    (is (nil? (parse-int "#{1}")))

    (is (nil? (parse-int "abcd_")))))

(run-tests 'services.parse-int_test)
