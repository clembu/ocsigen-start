(* This file was generated by Eliom-base-app.
   Feel free to use it, modify it, and redistribute it as you wish. *)

[%%shared
    open Eliom_content.Html.D
]

let%shared main_service_handler userid_o () () =
  %%%MODULE_NAME%%%_container.page userid_o (
    [
      p [em [pcdata "Eliom base app: Put app content here."]]
    ]
  )

let%shared about_handler userid_o () () =
  %%%MODULE_NAME%%%_container.page userid_o [
    div [
      p [pcdata "This template provides a skeleton \
                 for an Ocsigen application."];
      hr ();
      p [pcdata "Feel free to modify the generated code and use it \
                 or redistribute it as you want."]
    ]
  ]

let%server upload_user_avatar_handler myid () ((), (cropping, photo)) =
  let avatar_dir =
    List.fold_left Filename.concat
      (List.hd !%%%MODULE_NAME%%%_config.avatar_dir)
      (List.tl !%%%MODULE_NAME%%%_config.avatar_dir) in
  let%lwt avatar =
    Eba_uploader.record_image avatar_dir ~ratio:1. ?cropping photo in
  let%lwt user = Eba_user.user_of_userid myid in
  let old_avatar = Eba_user.avatar_of_user user in
  let%lwt () = Eba_user.update_avatar avatar myid in
  match old_avatar with
  | None -> Lwt.return ()
  | Some old_avatar ->
    Lwt_unix.unlink (Filename.concat avatar_dir old_avatar )

let () =
  (* Registering services. Feel free to customize handlers. *)
  Eliom_registration.Action.register
    ~service:Eba_services.set_personal_data_service'
    (Eba_session.connected_fun Eba_handlers.set_personal_data_handler');

  Eliom_registration.Action.register
    ~service:Eba_services.set_password_service'
    (Eba_session.connected_fun Eba_handlers.set_password_handler');

  Eliom_registration.Action.register
    ~service:Eba_services.forgot_password_service
    (Eba_handlers.forgot_password_handler Eba_services.main_service);

  Eliom_registration.Action.register
    ~service:Eba_services.preregister_service'
    Eba_handlers.preregister_handler';

  Eliom_registration.Action.register
    ~service:Eba_services.sign_up_service'
    Eba_handlers.sign_up_handler';

  Eliom_registration.Action.register
    ~service:Eba_services.connect_service
    Eba_handlers.connect_handler;

  Eliom_registration.Action.register
    ~service:Eba_services.disconnect_service
    Eba_handlers.disconnect_handler;

  Eliom_registration.Any.register
    ~service:Eba_services.activation_service
    Eba_handlers.activation_handler;

  %%%MODULE_NAME%%%_base.App.register
    ~service:Eba_services.main_service
    (%%%MODULE_NAME%%%_page.Opt.connected_page main_service_handler);

  %%%MODULE_NAME%%%_base.App.register
    ~service:%%%MODULE_NAME%%%_services.about_service
    (%%%MODULE_NAME%%%_page.Opt.connected_page about_handler) ;

  Eliom_registration.Ocaml.register
    ~service:%%%MODULE_NAME%%%_services.upload_user_avatar_service
    (Eba_session.connected_fun upload_user_avatar_handler)

let%client set_client_fun ~app ~service f : unit =
  Eliom_content.set_client_fun ~app ~service
    (fun get post ->
       let%lwt content = f get post in
       Eliom_client.set_content_local
         (Eliom_content.Html.To_dom.of_element content))

let%client () =
  let app = Eliom_client.get_application_name () in
  set_client_fun ~app ~service:%%%MODULE_NAME%%%_services.about_service
    (%%%MODULE_NAME%%%_page.Opt.connected_page about_handler);
  set_client_fun ~app ~service:%%%MODULE_NAME%%%_services.otdemo_service
    (%%%MODULE_NAME%%%_page.Opt.connected_page %%%MODULE_NAME%%%_otdemo.handler);
  set_client_fun ~app ~service:Eba_services.main_service
    (%%%MODULE_NAME%%%_page.Opt.connected_page main_service_handler)





(* Print more debugging information when <debugmode/> is in config file
   (DEBUG = yes in Makefile.options).
   Example of use:
   let section = Lwt_log.Section.make "%%%MODULE_NAME%%%:sectionname"
   ...
   Lwt_log.ign_info ~section "This is an information";
   (or ign_debug, ign_warning, ign_error etc.)
 *)
let _ =
  if Eliom_config.get_debugmode ()
  then begin
    ignore
      [%client (
        (* Eliom_config.debug_timings := true; *)
        (* Lwt_log_core.add_rule "eliom:client*" Lwt_log.Debug; *)
        (* Lwt_log_core.add_rule "eba*" Lwt_log.Debug; *)
        Lwt_log_core.add_rule "%%%MODULE_NAME%%%*" Lwt_log.Debug
        (* Lwt_log_core.add_rule "*" Lwt_log.Debug *)
        : unit ) ];
    (* Lwt_log_core.add_rule "*" Lwt_log.Debug *)
    Lwt_log_core.add_rule "%%%MODULE_NAME%%%*" Lwt_log.Debug
  end
