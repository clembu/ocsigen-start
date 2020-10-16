[%%client
(* This file was generated by Ocsigen Start.
   Feel free to use it, modify it, and redistribute it as you wish. *)

(* Carousel demo *)

open Eliom_content.Html]

[%%shared open Eliom_content.Html.F]

(* Service for this demo *)
let%server service =
  Eliom_service.create
    ~path:(Eliom_service.Path ["demo-carousel1"])
    ~meth:(Eliom_service.Get Eliom_parameter.unit) ()

(* Make service available on the client *)
let%client service = ~%service
(* Name for demo menu *)
let%shared name () = [%i18n Demo.S.carousel_1]
(* Class for the page containing this demo (for internal use) *)
let%shared page_class = "os-page-demo-carousel1"

(* Bind arrow keys *)
let%shared bind_keys change carousel =
  ignore
    [%client
      (let arrow_thread =
         (* Wait for the carousel to be in the page
          (in the case the page is generated client side): *)
         let%lwt () = Ot_nodeready.nodeready (To_dom.of_element ~%carousel) in
         Ot_carousel.bind_arrow_keys ~change:~%change
           Js_of_ocaml.Dom_html.document##.body
       in
       (* Do not forget to cancel the thread when we remove the carousel
        (here, when we go to another page): *)
       Eliom_client.onunload (fun () -> Lwt.cancel arrow_thread)
        : unit)]

(* Page for this demo *)
let%shared page () =
  let make_page name =
    div
      ~a:[a_class ["demo-carousel1-page"; "demo-carousel1-page-" ^ name]]
      [txt "Page "; txt name]
  in
  let carousel_change_signal =
    [%client
      (React.E.create ()
        : ([`Goto of int | `Next | `Prev] as 'a) React.E.t
          * (?step:React.step -> 'a -> unit))]
  in
  let update = [%client fst ~%carousel_change_signal] in
  let change = [%client fun a -> snd ~%carousel_change_signal ?step:None a] in
  let carousel_pages = ["1"; "2"; "3"; "4"] in
  let length = List.length carousel_pages in
  let carousel_content = List.map make_page carousel_pages in
  let {Ot_carousel.elt = carousel; pos; vis_elts} =
    Ot_carousel.make ~update carousel_content
  in
  let bullets = Ot_carousel.bullets ~change ~pos ~length ~size:vis_elts () in
  let prev = Ot_carousel.previous ~change ~pos [] in
  let next = Ot_carousel.next ~change ~pos ~vis_elts ~length [] in
  bind_keys change carousel;
  Lwt.return
    [ h1 [%i18n Demo.carousel_1]
    ; p [%i18n Demo.ot_carousel_first_example_1]
    ; p [%i18n Demo.ot_carousel_first_example_2]
    ; p [%i18n Demo.ot_carousel_first_example_3]
    ; p [%i18n Demo.ot_carousel_first_example_4]
    ; div
        ~a:[a_class ["demo-carousel1"]]
        [div ~a:[a_class ["demo-carousel1-box"]] [carousel; prev; next; bullets]]
    ]
