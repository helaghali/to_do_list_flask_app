from flask import Blueprint, render_template, redirect, url_for, request, flash
from .models import Task
from .forms import TaskForm
from . import db

bp = Blueprint('main', __name__)


@bp.route('/')
def index():
    return render_template('index.html')


@bp.route('/tasks')
def tasks():
    items = Task.query.order_by(Task.created_at.desc()).all()
    return render_template('tasks.html', tasks=items)


@bp.route('/tasks/add', methods=('GET', 'POST'))
def add_task():
    form = TaskForm()
    if form.validate_on_submit():
        t = Task(title=form.title.data, description=form.description.data, done=form.done.data)
        db.session.add(t)
        db.session.commit()
        flash('Task added.', 'success')
        return redirect(url_for('.tasks'))
    return render_template('task_form.html', form=form, action='Add')


@bp.route('/tasks/<int:id>/edit', methods=('GET', 'POST'))
def edit_task(id):
    task = Task.query.get_or_404(id)
    form = TaskForm(obj=task)
    if form.validate_on_submit():
        task.title = form.title.data
        task.description = form.description.data
        task.done = form.done.data
        db.session.commit()
        flash('Task updated.', 'success')
        return redirect(url_for('.tasks'))
    return render_template('task_form.html', form=form, action='Edit')


@bp.route('/tasks/<int:id>/delete', methods=('POST',))
def delete_task(id):
    task = Task.query.get_or_404(id)
    db.session.delete(task)
    db.session.commit()
    flash('Task deleted.', 'info')
    return redirect(url_for('.tasks'))

