# scoutcamp

A web app that uses [AngularDart](https://webdev.dartlang.org/angular) and
[AngularDart Components](https://webdev.dartlang.org/components).

NOTE: To run terraform, an github oauth token must be placed in local. The preferred way it to create a file `terraform/oauth.tf` with this content:

    locals {
      oauth = "<key>"
    }