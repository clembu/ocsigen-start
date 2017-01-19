(* This file was generated by Ocsigen Start.
   Feel free to use it, modify it, and redistribute it as you wish. *)

(* Os_tips demo *)

[%%shared
  open Eliom_content.Html.F
]

(* Service for this demo *)
let%server service =
  Eliom_service.create
    ~path:(Eliom_service.Path ["demo-tips"])
    ~meth:(Eliom_service.Get Eliom_parameter.unit)
    ()

(* Make service available on the client *)
let%client service = ~%service

(* Name for demo menu *)
let%shared name () = "Tips"

(* Class for the page containing this demo (for internal use) *)
let%shared page_class = "os-page-demo-tips"

(* Here is an example of tip. Call this function while generating the
   widget concerned by the explanation it contains. *)
let%shared example_tip () =
  (* Have a look at the API documentation of module Os_tips for
     more options. *)
  Os_tips.bubble ()
    ~top:40 ~right:0 ~width:300 ~height:180
    ~arrow:(`top 250)
    ~name:"example"
    ~content:[%client (fun _ ->
      Lwt.return
        Eliom_content.Html.F.[ p [%i18n example_tip]
                             ; p [%i18n look_module_tip]
                             ]) ]

(* Page for this demo *)
let%shared page () =
  (* Call the function defining the tip from the server or the client: *)
  let%lwt () = example_tip () in
  Lwt.return
    [ h1 [ pcdata "Tips for new users and new features" ]
    ; p [ pcdata "Module "
        ; code [ pcdata "Os_tips" ]
        ; pcdata " implements a way to display tips in the page and \
                   display them to the user who haven't already seen them."
        ]
    ; p [ pcdata "This page contains a tip, that you will see only as \
                  connected user, until you close it."
        ]
    ; p [ pcdata "It is possible to reset the set af already seen tips \
                  from the "
        ; a ~service:%%%MODULE_NAME%%%_services.settings_service
            [pcdata "settings page"] ()
        ; pcdata "."
        ]
    ]
