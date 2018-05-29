class cfg {
  static const server = "{{ os.environ['BACKEND_URL'] }}";
  static const signinUrl = "{{ os.environ['COGNITO_SIGNIN_URL'] }}";
}