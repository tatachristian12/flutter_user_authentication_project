from django.urls import path
from registration_form_api import views

urlpatterns = [
    path("user/", views.CreateAccountView.as_view()),
    path("user-profile/", views.UserProfileListView.as_view()),
    path("login/", views.LoginView.as_view()),
]