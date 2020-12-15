(ns test.index
  (:require [clojure.test :refer [run-tests]]))

(run-tests 'utils.coerce_test)
(run-tests 'services.parse-int_test)
(run-tests 'services.date_test)
