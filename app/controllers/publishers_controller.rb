# frozen_string_literal: true

class PublishersController < ApplicationController
  before_action :authenticate_user, only: %i[create update destroy]
  before_action :authorize_actions

  def index
    publishers = orchestrate_query(Publisher.all)
    render serialize(publishers)
  end

  def show
    render serialize(publisher)
  end

  def create
    if publisher.save
      render serialize(publisher).merge(status: :created, location: publisher)
    else
      unprocessable_entity! publisher
    end
  end

  def update
    if publisher.update(publisher_params)
      render serialize(publisher).merge(status: :ok)
    else
      unprocessable_entity! publisher
    end
  end

  def destroy
    publisher.destroy
    render status: :no_content
  end

  private

  def publisher
    @publisher ||= params[:id] ? Publisher.find(params[:id]) : Publisher.new(publisher_params)
  end
  alias resource publisher

  def publisher_params
    params.require(:data).permit(:name)
  end
end
