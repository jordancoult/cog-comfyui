from weights_downloader import WeightsDownloader
import custom_node_helpers as helpers
from node import Node
import json
import sys

# basically, just making a portable version of predict.py::predict::load_workflow

# the first goal would be to specify the workflow in an env var, which then gets loaded and stuff installed

# expected in directory: 
# - custom_node_helper.py
# - custom_node_helpers/

weights_downloader = WeightsDownloader()

def apply_helper_methods(method_name, *args, **kwargs):
    # Dynamically applies a method from helpers module with given args.
    # Example usage: self.apply_helper_methods("add_weights", weights_to_download, node)
    for module_name in dir(helpers):
        module = getattr(helpers, module_name)
        method = getattr(module, method_name, None)
        if callable(method):
            method(*args, **kwargs)

def handle_weights(workflow, weights_to_download=None):
    if weights_to_download is None:
        weights_to_download = []

    print("Checking weights")
    embeddings = weights_downloader.get_weights_by_type("EMBEDDINGS")
    embedding_to_fullname = {emb.split(".")[0]: emb for emb in embeddings}
    weights_filetypes = weights_downloader.supported_filetypes

    for node in workflow.values():
        apply_helper_methods("add_weights", weights_to_download, Node(node))

        for input in node["inputs"].values():
            if isinstance(input, str):
                if any(key in input for key in embedding_to_fullname):
                    weights_to_download.extend(
                        embedding_to_fullname[key]
                        for key in embedding_to_fullname
                        if key in input
                    )
                elif any(input.endswith(ft) for ft in weights_filetypes):
                    weights_to_download.append(input)

    weights_to_download = list(set(weights_to_download))

    for weight in weights_to_download:
        weights_downloader.download_weights(weight)

    print("====================================")

def handle_known_unsupported_nodes(workflow):
    for node in workflow.values():
        apply_helper_methods("check_for_unsupported_nodes", Node(node))

# Entry point: ComfyUI::load_workflow
def load_workflow(workflow):
    if not isinstance(workflow, dict):
        wf = json.loads(workflow)
    else:
        wf = workflow

    # There are two types of ComfyUI JSON
    # We need the API version
    if any(key in wf.keys() for key in ["last_node_id", "last_link_id", "version"]):
        raise ValueError(
            "You need to use the API JSON version of a ComfyUI workflow. To do this go to your ComfyUI settings and turn on 'Enable Dev mode Options'. Then you can save your ComfyUI workflow via the 'Save (API Format)' button."
        )

    handle_known_unsupported_nodes(wf)
    # handle_inputs(wf)  # unneeded
    handle_weights(wf)
    return wf


# main function that calls load workflow. the arg passed by user is the workflow json
# example usage: python installFromWorkflow.py workflow.json
if __name__ == "__main__":
    # get json file from arg
    workflow_path = sys.argv[1]
    with open(workflow_path, "r") as f:
        workflow = json.load(f)
    load_workflow(workflow)

# todo: update the provision script to install packages from this repo's cog