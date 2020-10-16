[%%shared
(* This file was generated by Ocsigen Start.
   Feel free to use it, modify it, and redistribute it as you wish. *)

open Eliom_content.Html.F]

[%%client
module Ocsigen_config = struct
  let get_debugmode () = false
end]

let%server css_name = !%%%MODULE_NAME%%%_config.css_name

let%client css_name =
  try Js_of_ocaml.Js.to_string Js_of_ocaml.Js.Unsafe.global##.___css_name_
  with _ -> ""

let%server css_name_script =
  [script (cdata_script (Printf.sprintf "var __css_name = '%s';" css_name))]

let%client css_name_script = []
(* Warning: either we use exactly the same global node (and make sure
   global nodes work properly on client side), or we do not add the
   script on client side.  We chose the second solution. *)
let%server app_js = [%%%MODULE_NAME%%%_base.App.application_script ~defer:true ()]
let%client app_js = []
let%server the_local_js = []
let%client the_local_js = [] (* in index.html *)
let%shared the_local_css = [[css_name]]

[%%shared
module Page_config = struct
  include Os_page.Default_config

  let title = "%%%PROJECT_NAME%%%"
  let local_js = the_local_js
  let local_css = the_local_css

  let other_head =
    meta
      ~a:
        [ a_name "viewport"
        ; a_content "width=device-width, initial-scale=1, user-scalable=no" ]
      ()
    :: css_name_script
    @ app_js

  let default_predicate _ _ = Lwt.return_true
  let default_connected_predicate _ _ _ = Lwt.return_true

  let default_error_page _ _ exn =
    %%%MODULE_NAME%%%_container.page None
      (if Ocsigen_config.get_debugmode ()
      then [p [txt (Printexc.to_string exn)]]
      else [p [txt "Error"]])

  let default_connected_error_page myid_o _ _ exn =
    %%%MODULE_NAME%%%_container.page myid_o
      (if Ocsigen_config.get_debugmode ()
      then [p [txt (Printexc.to_string exn)]]
      else [p [txt "Error"]])
end

include Os_page.Make (Page_config)]
