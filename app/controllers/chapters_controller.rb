class ChaptersController < ApplicationController
  require 'rails_autolink'
  def index
    @chapters = Chapter.active.order("chapter ASC")
    states = {}
    @chapters.each do |l|
      if states[l.state]
        states[l.state] << l.chapter
      else
        states[l.state] = [l.chapter]
      end
    end
    @states = states.to_a.sort

  respond_to do |format|
    format.html # index.html.erb
    format.json { render json: @chapters }
  end
end

  def show
    @chapter = Chapter.friendly.find(params[:id])
    #Make sure the chapter is active otherwise redirect to index
    if !@chapter.is_active
      redirect_to({ action: 'index' }, alert: @chapter.chapter + " is no longer an active chapter.")
    end
    if request.path != chapter_path(@chapter)
      redirect_to @chapter, status: :moved_permanently
    end
    @users = @chapter.admin_users
    @sponsors = @chapter.sponsors.active.order("sort_order ASC")

    @bios = @chapter.bios
    @leaders = @bios.where(title: "LEADERS").order("sort_order ASC")
    @organizers = @bios.where(title: "ORGANIZERS").order("sort_order ASC")
    @instructors = @bios.where(title: "INSTRUCTORS").order("sort_order ASC")
    @volunteers = @bios.where(title: "VOLUNTEERS").order("sort_order ASC")

    api = MeetupApi.new
    @events = api.events(group_id: @chapter.meetup_id)
  end
end
