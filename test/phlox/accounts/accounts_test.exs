defmodule Phlox.AccountsTest do
  use Phlox.DataCase
  
  alias Phlox.Accounts

  describe "users" do
    alias Phlox.Accounts.User

    @valid_attrs %{email: "some email", password: "password", password_confirmation: "password", username: "some username"}
    @update_attrs %{email: "some updated email", password: "password2", password_confirmation: "password2", username: "some updated username"}
    @invalid_attrs %{email: nil, password: nil, password_confirmation: nil, username: nil}
    @fixture_attrs %{email: "some email", password_digest: "ABCDE", username: "some username"}
    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end
    
    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.email == "some email"
      assert user.password == "password"
      assert user.password_confirmation == "password"
      assert user.username == "some username"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, user} = Accounts.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.email == "some updated email"
      assert user.password == "password2"
      assert user.password_confirmation == "password2"
      assert user.username == "some updated username"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end

    test "password_digest value gets set to a hash" do
      changeset = User.changeset(%User{}, @valid_attrs)
      assert Comeonin.Bcrypt.checkpw(@valid_attrs.password, Ecto.Changeset.get_change(changeset, :password_digest))
    end

    test "password_digest value does not get set if password is nil" do
      changeset = User.changeset(%User{}, %{email: "test@test.com", password: nil, password_confirmation: nil, username: "test"})
      refute Ecto.Changeset.get_change(changeset, :password_digest)
    end
  end
end