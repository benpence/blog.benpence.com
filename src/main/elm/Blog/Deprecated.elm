module Blog.Deprecated exposing ( .. )

import Task exposing ( Task, succeed, fail )

import                          Http

fromResult : Result x a -> Task x a
fromResult result =
  case result of
    Ok value ->
      succeed value

    Err msg ->
      fail msg

url : String -> List ( String, String ) -> String
url baseUrl query =
    case query of
        [] ->
            baseUrl

        _ ->
            let
                queryPairs =
                    query |> List.map (\( key, value ) -> Http.encodeUri key ++ "=" ++ Http.encodeUri value)

                queryString =
                    queryPairs |> String.join "&"
            in
                baseUrl ++ "?" ++ queryString
