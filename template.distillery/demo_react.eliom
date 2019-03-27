(* This file was generated by Ocsigen Start.
   Feel free to use it, modify it, and redistribute it as you wish. *)

(** Demo for shared reactive content *)

(* Service for this demo *)
let%server service =
  Eliom_service.create
    ~path:(Eliom_service.Path ["demo-react"])
    ~meth:(Eliom_service.Get Eliom_parameter.unit)
    ()

(* Make service available on the client *)
let%client service = ~%service

(* Name for demo menu *)
let%shared name () = [%i18n S.demo_reactive_programming]

(* Class for the page containing this demo (for internal use) *)
let%shared page_class = "os-page-demo-react"

(* Make a text input field that calls [f s] for each [s] submitted *)
let%shared make_form msg f =
  let inp = Eliom_content.Html.D.Raw.input ()
  and btn = Eliom_content.Html.(
    D.button ~a:[D.a_class ["button"]] [D.txt msg]
  ) in
  ignore [%client
    ((Lwt.async @@ fun () ->
      let btn = Eliom_content.Html.To_dom.of_element ~%btn
      and inp = Eliom_content.Html.To_dom.of_input ~%inp in
      Lwt_js_events.clicks btn @@ fun _ _ ->
      let v = Js_of_ocaml.Js.to_string inp##.value in
      let%lwt () = ~%f v in
      inp##.value := Js_of_ocaml.Js.string "";
      Lwt.return_unit)
     : unit)
  ];
  Eliom_content.Html.D.div [inp; btn]

(* Page for this demo *)
let%shared page () =
  (* Client reactive list, initially empty.
     It can be defined either from client or server side,
     (depending on whether this code is executed client or server-side).
     Use Eliom_shared.ReactiveData.RList for lists or
     Eliom_shared.React.S for other data types.
  *)
  let l, h = Eliom_shared.ReactiveData.RList.create [] in
  let inp =
    (* Form that performs a cons (client-side). *)
    make_form [%i18n S.demo_reactive_programming_button]
      [%client
        ((fun v -> Lwt.return (Eliom_shared.ReactiveData.RList.cons v ~%h))
         : string -> unit Lwt.t)
      ]
  and l =
    (* Produce <li> items from l contents.
       The shared function will first be called once server or client-side
       to compute the initial page. It will then be called client-side
       every time the reactive list changes to update the
       page automatically. *)
    Eliom_shared.ReactiveData.RList.map
      [%shared
        ((fun s -> Eliom_content.Html.(
           D.li [D.txt s]
         )) : _ -> _)
      ]
      l
  in
  Lwt.return Eliom_content.Html.[
    F.h1 [%i18n demo_reactive_programming]
  ; F.p [ F.txt [%i18n S.demo_reactive_programming_1]]
  ; F.p [ F.txt [%i18n S.demo_reactive_programming_2]]
  ; F.p [ F.txt [%i18n S.demo_reactive_programming_3]]
  ; inp
  ; F.div [R.ul l]
  ]
